# Case-study оптимизации

## Актуальная проблема
У нас есть программа, которая принимает на вход файл с информацией о сессиях юзеров в своем особом текстовом формате, и выдает отчет о сессиях в формате json.
Программа хорошо работала на небольших файлах, но с файлом больше ста мегабайт возникла проблема - программа отрабатывает настолько долго, что никто ни разу не дождался ее выполнения.
Необходимо оптимизировать программу так, чтобы файлы больше 100 Мб успешно обрабатывались за время <= 30 секунд.

## Формирование метрики
Ключевая метрика для нас — время выполнения программы. Мы включим в программу бенчмарк тесты, которые позволят прикинуть примерное время выполнения для 3.5 млн строк в исходном файле (примерно столько строк в файле data_large.txt).

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop
Наша проблема в том, что для построения эффективного фидбек лупа, мы не можем тестировать конечный бюджет (большой файл отрабатывает слишком долго), поэтому для начала нам надо провести анализ асимптотики, чтобы понять, какой выбрать размер входных данных, и какой бюджет у него должен быть целевым.
Для этого создадим простой вспомогательный тест для анализа асимптотики:

1. С помощью небольшого скрипта создадим несколько файлов с семплами данных `test/support/small_sample_generator.rb`.
Для начала разберемся, сколько юзеров в целевом сете данных.
```
> grep -R "^user" data_large.txt | wc -l
500000 // общее число юзеров
```

С помощью небольшого скрипта создадим семплы данных, на которых мы замерим выполнение программы.
```ruby
users_count = 0
sample_sizes = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

File.open('../../data_large.txt') do |f|
  sample_sizes.each do |sample_size|
    sample_file = File.open("small_samples/data_#{sample_size}.txt", 'w')
    f.each_line do |l|
      if l.start_with? 'user'
        break if users_count >= sample_size
        users_count += 1
      end
      sample_file << l
    end
    f.rewind
    users_count = 0
  end
end
```

Теперь в `test/support/small_samples/` у нас лежит много файлов с разным количеством юзеров.
2. Напишем простой бенчмарк, чтобы прикинуть асимптотику нашей программы.
Прежде, чем запускать бенч, не забываем закомментировать тест в тексте программы!
```ruby
require 'benchmark'
require_relative '../../task-1.rb'

SAMPLE_FILES = Dir['small_samples/*'].sort_by { |name| name[/\d+/].to_i } # сортируем файлы по размеру для наглядного вывода

Benchmark.bm do |x|
  SAMPLE_FILES.each do |f|
    x.report(f) do
      work(f)
    end
  end
end
```

Наш анализ показал следующие результаты:
```
                          user       system     total      real
small_samples/data_2.txt  0.000754   0.000906   0.001660 (  0.004021)
small_samples/data_4.txt  0.000646   0.000310   0.000956 (  0.000951)
small_samples/data_8.txt  0.000963   0.000128   0.001091 (  0.001091)
small_samples/data_16.txt  0.001778   0.000187   0.001965 (  0.001967)
small_samples/data_32.txt  0.003541   0.000368   0.003909 (  0.003911)
small_samples/data_64.txt  0.010460   0.000619   0.011079 (  0.011159)
small_samples/data_128.txt  0.029262   0.001191   0.030453 (  0.030673)
small_samples/data_256.txt  0.088735   0.005424   0.094159 (  0.096199)
small_samples/data_512.txt  0.249925   0.007075   0.257000 (  0.257684)
small_samples/data_1024.txt  0.968255   0.039844   1.008099 (  1.016977)
small_samples/data_2048.txt  5.987522   0.187155   6.174677 (  6.193528)
small_samples/data_4096.txt 24.672837   0.663667  25.336504 ( 25.527998)
```

Из этих данных видно, что алгоритм имеет сложность O(2^n) или даже O(n^3). Мы постараемся сделать его хотя бы линейным.
Тогда чтобы уложиться в поставленый бюджет, нам надо чтобы 2500 юзеров обсчитывались за 150 мс.
С помощью гема `rspec-benchmark` напишем простой тест, на который будем ориентироваться в процессе оптимизации программы.

```ruby
require_relative '../task-1.rb'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'task-1' do
  it 'works under 150ms' do
    expect {
      work('test/support/small_samples/data_2500.txt', disable_gc: true)
    }.to perform_under(150).ms.warmup(1).times.sample(5).times
  end
end
```

Тест отрабатывает за **10 секунд** вместо 150 мс — далеко от наших ожиданий.
Тест с включенной и выключенной сборкой мусора показал примерно одинаковое время работы программы (11 против 10 секунд).
Очевидно, сборка не занимает много времени процессора, однако, для чистоты наших результатов отключим GC на время итераций по оптимизации процессора.
Для начала, попробуем посмотреть на программу с помощью профилировщиков и оценить проблемные места в коде.

## Вникаем в детали системы, чтобы найти главные точки роста

Для того, чтобы найти "точки роста" для оптимизации посмотрим на отчет гема ruby-prof в режиме callgrind.

### Первая итерация
Из него находим первого претендента на оптимизацию — работа метода #select который вызывается методом #each из основной полезной функции #work,
занимает 93% времени процессора.

Селект очевидно проделывает огромное количество лишней работы - на каждого юзера мы итерируем все строки сессий, чтобы отсеять из них всего несколько
строк сессий, относящихся к нашему юзеру.
При этом мы уже однажды проходим по всем строкам файла для анализа в начале программы, когда собираем юзеров.
Чтобы избавиться от лишних итераций - сделаем всю работу за один проход. Для этого отрефакторим немного итерации по файлу.
Во-первых, избавимся от очевидно лишней переменной,
```ruby
file_lines = File.read(file_name).split("\n")

users = []
sessions = []

file_lines.each do |line|
  cols = line.split(',')
  users = users + [parse_user(line)] if cols[0] == 'user'
  sessions = sessions + [parse_session(line)] if cols[0] == 'session'
end
```
превратим ее в более идеоматическую итерацию по строкам:
```ruby
File.open(file_name).each_line do |l|
  cols = l.split(',')
  if cols[0] == 'user'
    current_user = parse_user(cols)
    users << current_user
  end
  if cols[0] == 'session'
    session = parse_session(cols)
    current_user.sessions << session
    sessions << session
  end
end
```

Прежде, чем проверять результат рефакторинга, не забудем раскомментировать тест и проверить правильность работы программы.
Ура, все работает как и прежде. Закомментируем тест обратно и замерим результат тестом производительности.

`expected block to perform under 150 ms, but performed above 282 ms (± 16 ms)`

Мы сократили время работы примерно в 30 раз и приблизились к бюджету.
Кстати, если теперь снова включить сборку мусора, то время выполнения теста будет около 350мс — теперь сборка мусора начинает быть заметной относительно общего времени.
Снова отключим GC и попробуем еще раз профилировать скрипт, чтобы найти новую точку роста.

### Вторая итерация

По новому отчету видим, что половину времени программа проводит в вызовах `#collect_stats_from_users`.
Если посмотреть в код — это несколько итераций по всем юзерам с целью сбора данных в репорт.
Можно немного изменить код, чтобы собирать всю стату за один проход.

```ruby
collect_stats_from_users(report, users) do |user|
  {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.',
    'longestSession' => user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.',
    'browsers' => user.sessions.map {|s| s['browser'].upcase}.sort.join(', '),
    'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
    'dates' => user.sessions.map {|s| Date.parse(s['date'])}.sort.reverse.map { |d| d.iso8601 },
  }
end
```

Тест показывает, что сильно сократить время работы за счет уменьшения проходов не удалось — время `#collect_stats_from_users` сократилось лишь с 46% до 41%.
Так же заметили, что второй претендент на оптимизацию — множество вызовов `#each` и `#all` прямо из тела `#work` — судя по коду это явно подсчет уникальных браузеров с итерацией по всем сессиям.
Попробуем сначала еще раз улучшить сборку статистики — встроим ее прямо в тот же цикл, где собираются все юзеры и сессии.
Это ухудшит читаемость кода, но возможно нам удастся существенно сократить время процессора.
```ruby
def collect_stats_from_user(report, user)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
  report['usersStats'][user_key] = {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.',
    'longestSession' => user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.',
    'browsers' => user.sessions.map {|s| s['browser'].upcase}.sort.join(', '),
    'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
    'dates' => user.sessions.map {|s| Date.parse(s['date'])}.sort.reverse.map { |d| d.iso8601 },
  }
end

File.open(file_name).each_line.with_index do |l, i|
  cols = l.split(',')
  if cols[0] == 'user'
    previous_user = current_user
    if !previous_user.nil?
      collect_stats_from_user(report, previous_user)
    end
    current_user = parse_user(cols)
    users << current_user
  end
  if cols[0] == 'session'
    session = parse_session(cols)
    current_user.sessions << session
    sessions << session
  end

  # handle last user
  collect_stats_from_user(report, current_user) if i == last_line_index
end
```

Замерим результат такого изменения.
`expected block to perform under 150 ms, but performed above 281 ms (± 20 ms)`
Печально — практически никакого выйгрыша. Вернем все обратно, чтобы не уродовать код в пустую (хорошо, что мы заранее закоммитились перед изменениями) и вернемся к другой находке — подсчету уникальных браузеров.

### Итерация 3
Попробуем сделать что-то вот с этим куском:
```ruby
uniqueBrowsers = []
sessions.each do |session|
  browser = session['browser']
  uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
end
```
Сделаем в лоб:
`uniqueBrowsers = sessions.map { |s| s['browser'] }.uniq`

Ура, наш перфоманс тест почти позеленел:
` expected block to perform under 150 ms, but performed above 166 ms (± 3.9 ms)`
Попробуем еще раз посмотреть в профилировщик.

### Итерация 4
Профилировщик как основную точку роста показывает парсинг данных юзера, который нам не удалось улучшить во второй итерации.
Согласно тесту, нам нехватает до бюджета совсем чуть-чуть, попробуем уменьшить количество работы `#map` и `Date.parse` — вторых претендентов на улучшение.

Первая идея, которая приходит в голову — сделать кеш дат. Ведь вряд ли количество дат в файле будет превышать несколько тысяч.
Однако, внимательный анализ входных данных показывает, что парсинг дат нам не нужен вообще.
Все, что нужно - это просто убрать у дат символ перехода строки.
Докажем это простым экспериментом.
Во-первых, распаршеные даты в формате iso8601 равны исходным данным:
```
pry(#<RSpec::ExampleGroups::Task1>)> dates = sessions.map { |s| s['date'].strip };nil
=> nil
pry(#<RSpec::ExampleGroups::Task1>)> dates.all? { |d| Date.parse(d).iso8601 == d }
=> true
```
Во-вторых, даты прекрасно сортируются в виде исходных строк:
```
pry(#<RSpec::ExampleGroups::Task1>)> users.first.sessions.map { |s| Date.parse(s['date']) }.sort.reverse.map(&:iso8601)
=> ["2019-02-04", "2018-02-01", "2017-11-30", "2017-11-21", "2017-10-28", "2017-05-31", "2016-11-02", "2016-08-22"]
pry(#<RSpec::ExampleGroups::Task1>)> users.first.sessions.map { |s| s['date'].strip }.sort.reverse
=> ["2019-02-04", "2018-02-01", "2017-11-30", "2017-11-21", "2017-10-28", "2017-05-31", "2016-11-02", "2016-08-22"]
```

Воспользуемся этим открытием и попробуем полностью избавиться от затратной операции.
`'dates' => user.sessions.map {|s| s['date']}.sort.reverse,`

Убедимся в правильности работы программы и замерим результат.
Тест зеленый! По факту, мы даже достигли цифры в 100мс.
Даже с включенной сборкой мусора, тест лишь иногда переваливает за показатель в 100мс.
Попробуем теперь обработать исходный файл.
```
$ time ruby task-1.rb
ruby task-1.rb  50.77s user 1.84s system 98% cpu 53.391 total
```
К сожалению, исходный файл обрабатывается около 50 секунд. Пойдем на еще одно ухищрение.

### Итерация 5

Мы можем cделать скрипт более производительным, если разделим файл на две части, обработаем их в отдельных процессах и потом смержим хеши с репортом.
Единственный минус — для одноядерных машин это не даст никакого выйгрыша.

Возьмем гем `parallel` который позволяет сделать форк и собрать результаты исполнения программы в памяти исходного процесса.
Между тем, программа становится все уродливее :D
```ruby
def work(file_name, disable_gc: false)
  GC.disable if disable_gc

  users_count = `grep -R "^user" #{file_name} | wc -l`.strip.split(' ')[0].to_i

  report = {}

  if users_count > 100_000
    f1, f2 = split_work(file_name)
    report = do_hard_work(f1, f2)
    File.delete(f1) if File.exist?(f1)
    File.delete(f2) if File.exist?(f2)
  else
    report = do_small_work(file_name)
  end
  File.write('result.json', "#{report.to_json}\n")
end


def do_hard_work(f1, f2)
  reports = Parallel.map([f1, f2], in_processes: 2) { |file_name| do_small_work(file_name) }
  reports[0].merge!(reports[1])
end

def do_small_work(file_name)
  # тут всё то же что было в старом work, только результат возвращается в виде хеша
end
```

Посмотрим, что у нас получилось.
```
$ time ruby task-1.rb
ruby task-1.rb  52.50s user 2.85s system 179% cpu **30.911 total**
```
УРА! Тест рспек также проходит.
```
it 'performs under 31 sec for large file' do
  expect {
    work('data_large.txt')
  }.to perform_under(31000).ms.warmup(1).times.sample(2).times
end
```

```
$ rspec test/perf-test.rb
.

Finished in 1 minute 31.42 seconds (files took 0.23075 seconds to load)
  1 example, 0 failures
```

## Результаты
В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с бесконечно большой до 30 секунд и уложиться в заданный бюджет.

## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы будем использовать rspec-benchmark с проверкой для маленького и большого файла.

```
describe 'task-1' do
  it 'performs under 150ms for small file' do
    expect {
      work('test/support/small_samples/data_2500.txt', disable_gc: false)
    }.to perform_under(110).ms.warmup(1).times.sample(5).times
  end

  it 'performs under 31 sec for large file' do
    expect {
      work('data_large.txt')
    }.to perform_under(31000).ms.warmup(1).times.sample(2).times
  end
end
```

