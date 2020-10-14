# Case-study оптимизации

## Актуальная проблема
В нашем проекте возникла серьёзная проблема:

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики
Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я написал простейший бенчмарк, последовательно тестирующий время выполнения программы с разным количеством строк:

```ruby

require 'benchmark'

require 'ruby-prof'
require_relative 'task-1'

File.write('result.json', '')

def prepare_data_file(user_count = 1)
  File.write('data.txt',
             'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
' * user_count)
end

user_counts = [1, 5, 10, 50, 100, 500]
user_counts.each do |count|
  prepare_data_file(count)
  user_time = Benchmark.realtime do
    work
  end
  puts "finished #{count} user(s) in #{user_time}"
end
```

Первый прогон бенчмарка дал результаты, от которых можно было отталкиваться:

```shell

finished 1 user(s) in 0.000670084999910614
finished 5 user(s) in 0.00102659899948776
finished 10 user(s) in 0.0035505199994076975
finished 50 user(s) in 0.08020978599961381
finished 100 user(s) in 0.33428546499999356
finished 500 user(s) in 8.259295051000663
```
Видно, что время выполнения растет нелинейно, сложность алгоритма O(N^N). С этим нужно было что-то делать.

## Гарантия корректности работы оптимизированной программы
Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.
Этот тест запускался по мере необходимости после внесения изменений в программу и перед бенчмарками.

## Feedback-Loop
Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил удобный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений.
`feedback-loop` рос и модифицировался по мене необходимости. Сначала это был один тест с последовательным прогоном нескольких записей с (`1, 5, 10, 50, 100, 500`) и выводом времени выполнения
Затем к тесту добавились отчеты `ruby-prof` и `stackprof`. Каждый из них помогал в свое время, однако основным стал `Flat` отчет `ruby-prof` с выводом в `STDOUT`. 
Это позволяло получить обратную связь оперативнее сразу в консоли.


## Вникаем в детали системы, чтобы найти главные точки роста

При замене строки в task-1.rb:47 на file_lines = File.read('data_large.txt').split("\n") программа виснет, не подавая признаков жизни. top показывает потребление CPU при этом в диапазоне 99-100%, потребление памяти стабильно в районе 1,9-2%.
Подключился к подвешенному процессу через rbspy, увидел такую картину:

```bash
Time since start: 18s. Press Ctrl+C to stop.
Summary of profiling data so far:
% self  % total  name
 99.72    99.94  block in work - task-1.rb
  0.17     0.17  parse_session - task-1.rb
  0.06   100.00  <c function> - unknown
  0.06     0.06  parse_user - task-1.rb
  0.00   100.00  work - task-1.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  time_it - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  test_result - task-1.rb
  0.00   100.00  run_one_method - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  on_signal - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  capture_exceptions - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in autorun - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in __run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block (3 levels) in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block (2 levels) in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
```

Большую часть процессорного времени на себя берет метод work. К сожалению, он достаточно массивный, для анализа требуется разбить его на более мелкие методы. 
Сперва в отдельный метод `file_lines_iteration` был выведен блок 
```bash
file_lines.each do |line|
    cols = line.split(',')
    users = users + [parse_user(line)] if cols[0] == 'user'
    sessions = sessions + [parse_session(line)] if cols[0] == 'session'
  end
```
После прогона rbspy видим, что теперь file_lines_iteration возглавляет список:

```bash
Time since start: 9s. Press Ctrl+C to stop.
Summary of profiling data so far:
% self  % total  name
 99.34   100.00  block in file_lines_iteration - task-1.rb
  0.33   100.00  <c function> - unknown
  0.22     0.22  parse_user - task-1.rb
  0.11     0.11  parse_session - task-1.rb
  0.00   100.00  work - task-1.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  with_info_handler - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  time_it - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  test_result - task-1.rb
  0.00   100.00  run_one_method - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  on_signal - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  file_lines_iteration - task-1.rb
  0.00   100.00  capture_exceptions - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest/test.rb
  0.00   100.00  block in run - /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/minitest-5.14.2/lib/minitest.rb
  0.00   100.00  block in autorun - /
```
Из метода `file_lines_iteration` выделил содержимое в отдельный метод `process_line`, прогнал тест, посмотрел отчет `ruby-prof#callgrid`, ожидаемо увидел, что теперь `process_line` вызывается чаще всего.
Разбил метод на несколько таким образом:

```ruby
def parse_user_and_add_to_user(cols, line, users)
  users = users + [parse_user(line)] if cols[0] == 'user'
end

def parse_session_and_add_to_sessions(cols, line, sessions)
  sessions = sessions + [parse_session(line)] if cols[0] == 'session'
end

def work
  file_lines = File.read('data.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    parse_user_and_add_to_user(cols, line, users)
    parse_session_and_add_to_sessions(cols, line, sessions)
  end
# <------->
end
```
После изменения упал тест. Изменения откатил.
Сконцентрировался на `collect_stats_from_single_user`:

![collect_stats_from_single_user](https://github.com/theendcomplete/rails-optimization-task1/blob/task_1/case-study-media/Untitled%204.png?raw=true)

Для уточнения направления движения обратился к лекциям и вспомнил про инструмент `stackprof`.
Добавил в бенчмарк и сформировал отчет:

 ```bash
 (base) theendcomplete@N10L:~/Documents/projects/my/rails-optimization-task1$ stackprof stackprof_reports/sp.dump 
 ==================================
   Mode: wall(1200)
   Samples: 807 (0.00% miss rate)
   GC: 127 (15.74%)
 ==================================
      TOTAL    (pct)     SAMPLES    (pct)     FRAME
        529  (65.6%)         529  (65.6%)     Object#dates
         65   (8.1%)          65   (8.1%)     (marking)
         62   (7.7%)          62   (7.7%)     (sweeping)
         40   (5.0%)          40   (5.0%)     Object#browsers
         37   (4.6%)          37   (4.6%)     Object#fill_sessions
         27   (3.3%)          27   (3.3%)     Object#total_time
         26   (3.2%)          26   (3.2%)     Object#longest_session
          9   (1.1%)           9   (1.1%)     Object#always_used_chrome?
          8   (1.0%)           8   (1.0%)     Object#used_ie?
          2   (0.2%)           2   (0.2%)     Object#fill_user_key
          1   (0.1%)           1   (0.1%)     Object#parse_session
          1   (0.1%)           1   (0.1%)     Object#browser_uniq?
        680  (84.3%)           0   (0.0%)     Object#work
        680  (84.3%)           0   (0.0%)     block in <main>
        680  (84.3%)           0   (0.0%)     <main>
        680  (84.3%)           0   (0.0%)     <main>
        127  (15.7%)           0   (0.0%)     (garbage collection)
        641  (79.4%)           0   (0.0%)     Object#collect_all_stats
        639  (79.2%)           0   (0.0%)     Object#fill_usersStats
        641  (79.4%)           0   (0.0%)     Object#collect_stats_from_single_user
        641  (79.4%)           0   (0.0%)     Object#collect_stats_from_users
```

Пересмотрел условие задания и приложенный тест - необходимости в конвертации дат в формат `iso8601` нет, так как сортировка их строкового представления даст тот же результат.
Проверил предположение в `irb`, отрефакторил `task-1.rb`, выпилил конвертацию дат, результат:

```
finished 1 user(s) in 0.00033806299961725017
finished 5 user(s) in 0.001485999000578886
finished 10 user(s) in 0.004655684999306686
finished 50 user(s) in 0.05858576900027401
finished 100 user(s) in 0.2136470109999209
finished 500 user(s) in 5.362461220000114
```  
Скорость парсинга значительно возросла, но все еще не линейно зависит от количества строк. 
Продолжаем.

После нескольких незначительных итераций сформировал `graph` отчет `ruby-prof`, изучил его:
![graph](https://github.com/theendcomplete/rails-optimization-task1/blob/task_1/case-study-media/Untitled%206.png?raw=true)

также изучил `stackprof`:
```bash
==================================
  Mode: wall(1200)
  Samples: 3380 (0.00% miss rate)
  GC: 139 (4.11%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
       867  (25.7%)         867  (25.7%)     Object#browsers
       853  (25.2%)         853  (25.2%)     Object#fill_sessions
       684  (20.2%)         485  (14.3%)     Object#dates
       274   (8.1%)         274   (8.1%)     Object#used_ie?
       199   (5.9%)         199   (5.9%)     Object#map_sessions
       189   (5.6%)         189   (5.6%)     Object#total_time
       182   (5.4%)         182   (5.4%)     Object#always_used_chrome?
       173   (5.1%)         173   (5.1%)     Object#longest_session
```
После оптимизации итараций по сессиям при подсчете браузеров:
```
finished 1 user(s) in 0.0003254610001022229
finished 5 user(s) in 0.0006570820005435962
finished 10 user(s) in 0.0020394210005179048
finished 50 user(s) in 0.042648007000025245
finished 100 user(s) in 0.13969823499974154
finished 500 user(s) in 4.1186264629996 
```
Также к этому моменту наконец-то осознал необходимость прогрессбара, поэкспериментировал с разными вариантами и их влиянием на проихводительность.
Само собой, что добавление подсчета оставшегося времени выполнения сказывается негативно, но удобства отображения того стоит.

Уткнулся в Array#each:
```
Measure Mode: wall_time
Thread ID: 1620
Fiber ID: 1600
Total: 1008.423798
Sort by: self_time

 %self      total      self      wait     child     calls  name                           location
 90.89   1002.617   916.544     0.000    86.074   560626  *Array#each                     
  0.97      9.831     9.831     0.000     0.000  3250941   String#split                   
  0.61     53.037     6.136     0.000    46.901  3750942   ProgressBar::Output#with_refresh /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:42
  0.51     34.017     5.099     0.000    28.918  3750942   ProgressBar::Output#refresh    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:47
  0.40      5.807     4.080     0.000     1.727  7532190   ProgressBar::Base#finished?    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:80
  0.37      7.222     3.687     0.000     3.535  3750944   ProgressBar::Progress#progress= /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:61
  0.36      5.283     3.670     0.000     1.613  2750940   Object#parse_session           /home/theendcomplete/Documents/projects/my/rails-optimization-task1/task-1.rb:17
  0.35     22.914     3.569     0.000    19.345  3750942   ProgressBar::Throttle#choke    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/throttle.rb:15
  0.32      4.063     3.245     0.000     0.818  3841866   <Class::Time>#now              
  0.27     12.548     2.742     0.000     9.806  3811556   ProgressBar::Timer#elapsed_seconds /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:53
  0.27     57.771     2.710     0.000    55.061  3750940   ProgressBar::Base#increment    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:92
  0.26      9.828     2.606     0.000     7.222  3750940   ProgressBar::Progress#increment /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:37
  0.25      7.775     2.538     0.000     5.237  3841866   ProgressBar::Time#now          /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/time.rb:15
  0.23      6.071     2.315     0.000     3.756  3781252   ProgressBar::Base#stopped?     /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:74
  0.23      2.643     2.285     0.000     0.358  1500000   User#key                       /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:20
  0.20     55.061     2.024     0.000    53.037  3750942   ProgressBar::Base#update_progress /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:176
  0.18      2.496     1.866     0.000     0.630  3750944   <Class::ProgressBar::Calculators::RunningAverage>#calculate /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/running_average.rb:4
  0.17      1.737     1.737     0.000     0.000  7562500   ProgressBar::Progress#finished? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:33
  0.15      1.540     1.540     0.000     0.000  2750940   String#=~                      
  0.15      1.517     1.517     0.000     0.000  1000001   Array#sort                     
  0.14      6.954     1.458     0.000     5.496   500000   User#user_stats                /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:44
  0.14      2.096     1.402     0.000     0.694  3811556   Time#-                         
  0.13      9.940     1.271     0.000     8.669   500000   User#initialize                /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:6
  0.12      1.174     1.174     0.000     0.000  3841866   ProgressBar::Time#unmocked_time_method /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/time.rb:19
  0.10      1.039     1.039     0.000     0.000  3750944   ProgressBar::Progress#absolute /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:114
  0.10      1.029     1.029     0.000     0.000        2   Array#flatten                  
  0.10      1.024     1.024     0.000     0.000  3841870   ProgressBar::Timer#stopped?    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:35
  0.10      1.022     1.022     0.000     0.000        1   JSON::Ext::Generator::GeneratorMethods::Hash#to_json 
  0.10      1.004     1.004     0.000     0.000  2750940   String#upcase                  
  0.10      1.002     1.002     0.000     0.000   500001   Array#join                     
  0.10      1.000     1.000     0.000     0.000  3781256   ProgressBar::Timer#started?    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:31
  0.09      0.900     0.900     0.000     0.000        1   Array#map                      
  0.08      2.387     0.847     0.000     1.540  2750940   Kernel#!~                      
  0.08      0.818     0.818     0.000     0.000  3841866   Time#initialize                
  0.07      0.694     0.694     0.000     0.000  3811556   Integer#fdiv                   
  0.07     10.628     0.687     0.000     9.941   500042  *Class#new                      
  0.07      0.673     0.673     0.000     0.000  3750960   Hash#fetch                     
  0.07      0.667     0.667     0.000     0.000   212170   String#gsub!                   
  0.06      0.630     0.630     0.000     0.000  3750948   Integer#*                      
  0.06      0.609     0.609     0.000     0.000  2750940   String#to_i                    
  0.05      0.543     0.543     0.000     0.000  1030310   Integer#to_s                   
  0.05      0.525     0.525     0.000     0.000   500000   Object#parse_user              /home/theendcomplete/Documents/projects/my/rails-optimization-task1/task-1.rb:8
  0.05      0.496     0.496     0.000     0.000   500004   Hash#merge                     
  0.05      1.031     0.490     0.000     0.541   500000   User#sessions_total_time       /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:28
  0.05      2.482     0.464     0.000     2.018   500000   User#browsers                  /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:24
  0.04      0.442     0.442     0.000     0.000  1030310   String#+                       
  0.04      0.419     0.419     0.000     0.000        1   Array#uniq                     
  0.04      8.669     0.398     0.000     8.272   500000   User#init_session_stats        /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:56
  0.04      0.388     0.388     0.000     0.000  1151550   String#to_s                    
  0.04      2.221     0.374     0.000     1.847   181860   ProgressBar::Format::Molecule#lookup_value /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/molecule.rb:49
  0.04      0.773     0.369     0.000     0.404   500000   User#longest_session           /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:32
  0.03      0.341     0.341     0.000     0.000    30314   IO#write                       
  0.03      0.280     0.280     0.000     0.000   500000   User#chrome_fan?               /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:40
  0.03      0.274     0.274     0.000     0.000        1   <Class::IO>#write              
  0.03      0.273     0.273     0.000     0.000    60618   String#%                       
  0.02      0.228     0.228     0.000     0.000   500000   User#used_ie?                  /home/theendcomplete/Documents/projects/my/rails-optimization-task1/models/user.rb:36
  0.02      0.221     0.221     0.000     0.000   500000   Array#reverse                  
  0.02      0.218     0.218     0.000     0.000    30310   ProgressBar::Calculators::Length#unix? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:95
  0.02      0.162     0.162     0.000     0.000    30312   IO#tty?                        
  0.01      3.674     0.151     0.000     3.524    30310   <Class::ProgressBar::Format::Formatter>#process /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/formatter.rb:4
  0.01   1008.424     0.111     0.000  1008.313        1   Object#work                    /home/theendcomplete/Documents/projects/my/rails-optimization-task1/task-1.rb:28
  0.01      0.334     0.102     0.000     0.232    30308   ProgressBar::Components::Time#estimated_seconds_remaining /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:91
  0.01      0.134     0.099     0.000     0.035    30311   Kernel#dup                     
  0.01      0.096     0.096     0.000     0.000   181860   ProgressBar::Format::Molecule#full_key /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/molecule.rb:45
  0.01      0.566     0.096     0.000     0.470    30312   ProgressBar::Components::Time#elapsed /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:79
  0.01      4.436     0.091     0.000     4.345    30310   ProgressBar::Output#print_and_flush /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:63
  0.01      0.104     0.081     0.000     0.024    90930   ProgressBar::Progress#percentage_completed /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:83
  0.01      0.139     0.075     0.000     0.064   181884   ProgressBar::Format::Molecule#bar_molecule? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/molecule.rb:37
  0.01      0.073     0.073     0.000     0.000        1   <Class::IO>#read               
  0.01      0.070     0.070     0.000     0.000   212196   Array#include?                 
  0.01      3.787     0.066     0.000     3.721    30310   ProgressBar::Base#to_s         /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:120
  0.01      0.617     0.066     0.000     0.551    30310   ProgressBar::Calculators::Length#terminal_width /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:43
  0.01      0.098     0.065     0.000     0.033    60618   ProgressBar::Timer#divide_seconds /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:61
  0.01      0.463     0.064     0.000     0.399    30308   ProgressBar::Components::Time#estimated /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:65
  0.01      0.333     0.063     0.000     0.270    30310   ProgressBar::Calculators::Length#dynamic_width /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:57
  0.01      0.201     0.058     0.000     0.143    30310   ProgressBar::Timer#restart     /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:48
  0.01      0.053     0.053     0.000     0.000    30310   IO#winsize                     
  0.01      0.127     0.052     0.000     0.075    60620   ProgressBar::Components::Bar#completed_length /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:91
  0.01      0.633     0.052     0.000     0.581    30310   ProgressBar::Components::Time#estimated_with_unknown_oob /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:38
  0.01      0.708     0.052     0.000     0.657    30310   ProgressBar::Calculators::Length#length_changed? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:18
  0.00      0.050     0.050     0.000     0.000    30310   String#gsub                    
  0.00      3.835     0.048     0.000     3.787    30310   ProgressBar::Outputs::Tty#bar_update_string /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/outputs/tty.rb:15
  0.00      0.614     0.047     0.000     0.566    30312   ProgressBar::Components::Time#elapsed_with_label /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:26
  0.00      0.047     0.047     0.000     0.000    60622   String#*                       
  0.00      0.160     0.045     0.000     0.115    30310   ProgressBar::Components::Bar#incomplete_space /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:75
  0.00      0.180     0.042     0.000     0.139    30310   ProgressBar::Components::Bar#bar /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:51
  0.00      0.550     0.041     0.000     0.509    30310   ProgressBar::Components::Time#estimated_with_elapsed_fallback /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:87
  0.00      0.115     0.041     0.000     0.074    30312   ProgressBar::Timer#start       /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:12
  0.00      0.657     0.040     0.000     0.617    30310   ProgressBar::Calculators::Length#calculate_length /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:25
  0.00      0.121     0.040     0.000     0.082    30310   ProgressBar::Format::String#displayable_length /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/string.rb:7
  0.00      0.139     0.039     0.000     0.100    30310   ProgressBar::Components::Bar#standard_complete_string /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:43
  0.00      0.499     0.036     0.000     0.463    30308   ProgressBar::Components::Time#estimated_with_label /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:22
  0.00      0.056     0.034     0.000     0.022    30308   ProgressBar::Progress#none?    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:95
  0.00      0.033     0.033     0.000     0.000   121236   Integer#divmod                 
  0.00      0.032     0.032     0.000     0.000    60618   ProgressBar::Progress#unknown? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:99
  0.00      0.077     0.032     0.000     0.045    30310   ProgressBar::Components::Percentage#percentage /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/percentage.rb:12
  0.00      0.372     0.032     0.000     0.341    30314   IO#print                       
  0.00      0.032     0.032     0.000     0.000    30310   String#length                  
  0.00      0.105     0.031     0.000     0.074    30310   ProgressBar::Components::Bar#incomplete_string /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:47
  0.00      0.097     0.031     0.000     0.067    30310   ProgressBar::Outputs::Tty#eol  /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/outputs/tty.rb:27
  0.00      0.083     0.030     0.000     0.053    30310   ProgressBar::Calculators::Length#dynamic_width_via_output_stream_object /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:73
  0.00      0.156     0.029     0.000     0.127    30312   ProgressBar::Timer#elapsed_whole_seconds /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:57
  0.00      0.029     0.029     0.000     0.000    30310   ProgressBar::Timer#reset       /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:39
  0.00      0.046     0.028     0.000     0.018    30310   ProgressBar::Output#length     /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:38
  0.00      0.028     0.028     0.000     0.000    30310   ProgressBar::Format::String#non_bar_molecules /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/string.rb:15
  0.00      0.031     0.026     0.000     0.006    30312   ProgressBar::Components::Time#out_of_bounds_time_format= /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:54
  0.00      0.025     0.025     0.000     0.000    30326   Kernel#respond_to?             
  0.00      0.024     0.024     0.000     0.000    90930   Integer#to_i                   
  0.00      0.035     0.021     0.000     0.014    30311   Kernel#initialize_dup          
  0.00      0.021     0.021     0.000     0.000    30310   ProgressBar::Format::String#bar_molecule_placeholder_length /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/string.rb:11
  0.00      0.019     0.019     0.000     0.000    30306   Float#round                    
  0.00      0.018     0.018     0.000     0.000    30312   ProgressBar::Calculators::Length#length /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:14
  0.00      0.016     0.016     0.000     0.000    30306   Integer#/                      
  0.00      0.015     0.015     0.000     0.000    60620   Integer#floor                  
  0.00      0.014     0.014     0.000     0.000    30310   IO#flush                       
  0.00      0.014     0.014     0.000     0.000    30310   String#initialize_copy         
  0.00      0.013     0.013     0.000     0.000    30312   Float#floor                    
  0.00      0.013     0.013     0.000     0.000    30312   ProgressBar::Format::String#bar_molecules /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/string.rb:19
  0.00      0.011     0.011     0.000     0.000    30306   Numeric#zero?                  
  0.00      0.011     0.011     0.000     0.000    30308   Float#zero?                    
  0.00      0.010     0.010     0.000     0.000        2   Hash#values                    
  0.00      0.009     0.009     0.000     0.000    30306   Float#-                        
  0.00      0.001     0.000     0.000     0.001        2   <Class::ProgressBar>#create    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar.rb:19
  0.00   1008.424     0.000     0.000  1008.424        1   [global]#                      benchmark.rb:22
  0.00      0.001     0.000     0.000     0.001        2   ProgressBar::Base#initialize   /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:16
  0.00      0.000     0.000     0.000     0.000        2   String#scan                    
  0.00      0.000     0.000     0.000     0.000        4   Array#select                   
  0.00      0.000     0.000     0.000     0.000       12   ProgressBar::Format::Molecule#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/molecule.rb:32
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Timer#stop        /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:17
  0.00      0.000     0.000     0.000     0.000        2   <Object::Object>#[]            
  0.00      0.000     0.000     0.000     0.000        4   ProgressBar::Progress#start    /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:23
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Progress#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:16
  0.00      0.000     0.000     0.000     0.000       12   String#to_sym                  
  0.00      0.000     0.000     0.000     0.000       12   ProgressBar::Format::Molecule#non_bar_molecule? /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/molecule.rb:41
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Output#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:7
  0.00      0.000     0.000     0.000     0.000        4   ProgressBar::Format::String#molecules /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/format/string.rb:23
  0.00      0.000     0.000     0.000     0.000        4   ProgressBar::Timer#initialize  /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/timer.rb:8
  0.00      0.001     0.000     0.000     0.000        2   ProgressBar::Base#start        /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/base.rb:39
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Components::Rate#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/rate.rb:10
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Calculators::Length#length_override= /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:33
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Outputs::Tty#clear /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/outputs/tty.rb:10
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Components::Time#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/time.rb:16
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Components::Bar#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/bar.rb:17
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Calculators::Length#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/calculators/length.rb:8
  0.00      0.000     0.000     0.000     0.000        2   <Class::ProgressBar::Output>#detect /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:17
  0.00      0.000     0.000     0.000     0.000        2   Kernel#lambda                  
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Throttle#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/throttle.rb:8
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Output#clear_string /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/output.rb:34
  0.00      0.000     0.000     0.000     0.000        4   Enumerable#find                
  0.00      0.000     0.000     0.000     0.000        2   String#initialize              
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Progress#total=   /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/progress.rb:74
  0.00      0.000     0.000     0.000     0.000       12   String#[]                      
  0.00      0.000     0.000     0.000     0.000        4   ProgressBar::Time#initialize   /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/time.rb:11
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Components::Percentage#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/percentage.rb:6
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Components::Title#initialize /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/components/title.rb:8
  0.00      0.000     0.000     0.000     0.000        1   JSON::Ext::Generator::State#initialize_copy 
  0.00      0.000     0.000     0.000     0.000        2   ProgressBar::Outputs::Tty#resolve_format /home/theendcomplete/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/ruby-progressbar-1.10.1/lib/ruby-progressbar/outputs/tty.rb:23
  0.00      0.000     0.000     0.000     0.000        2   Kernel#is_a?                   

* recursively called methods

Columns are:

  %self     - The percentage of time spent in this method, derived from self_time/total_time.
  total     - The time spent in this method and its children.
  self      - The time spent in this method.
  wait      - The amount of time this method waited for other threads.
  child     - The time spent in this method's children.
  calls     - The number of times this method was called.
  name      - The name of the method.
  location  - The location of the method.

The interpretation of method names is:

  * MyObject#test - An instance method "test" of the class "MyObject"
  * <Object:MyObject>#test - The <> characters indicate a method on a singleton class.
```
Через некоторое время понял, что множество итераций вызывается при подсчете статистики по пользователю.
Стал хранить сессии всех пользователей в хэше с ключом `user_id`. Это значительно улучшило картину, но в бюджет я все еще не укладывался, большой файл грузился ~за 15 минут.
В топе все так же был `Array#each`.
Стало ясно, что нужно собирать статистику сразу при чтении файла, за 1 проход.
Изучил формат файла для импорта, понял, что сначала всегда идет пользователь, а затем - его сессии. Исходя из этого переписал импорт таким образом:

```
file_lines.each do |line|
    fields = line.split(',')
    if fields[0] == 'user'
      user = User.new(attributes: parse_user(fields), sessions: [])
      users[fields[1]] = user
      users_count += 1
      unless prev_user.eql?(user)
        # form report for previously imported user
        report_user(prev_user, users_stats) if prev_user
        prev_user = user
      end
    end

    if fields[0] == 'session'
      user = users[fields[1]]
      user.sessions << parse_session(fields)
      user.browsers << fields[3].upcase
      browsers << fields[3].upcase
      browsers_count += 1
      user.session_durations << fields[4].to_i
      user.session_dates << fields[5]
      sessions_count += 1
    end

    progressbar.increment
  end
  # reporting last user
  report_user(prev_user, users_stats)

```
С отключенным GC время обработки файла сократилось до ~17 секунд, с включенным - в районе 25.

### Ваша находка №2
- самымы полезными отчетами оказались `ruby-prof#callgrid` и `stackprof`
- самая высокая точка роста - сбор данных по сессиям пользователей
- избавление от лишних вложенных циклов позволило впотную приблизить рост времени обработки к линейной зависимости от объема данных 
- в соответствии с вносимыми корректировками в код программы точка роста изменялась. Не всегда изменения были к лучшему.


### Ваша находка №1
- при использовании неоптимального алгоритма рассчитывать на высокую производительность не приходится 
- использование подходящих структур для хранения данных дает весьма заметный прирост в произмодительности
- линтеры помогают, но не решают проблемы за разработчика

### Ваша находка №3
- нельзя недооценивать feedback-Loop, в самом начале стоит не жалеть времени на его проектирование
- о ведении заметок нельзя забывать ни на минуту. Заметки в текстовом формате предпочтительнее изображений
- возможности к дальнейшей оптимизации есть, например, использование специализированных библиотек для работы с `CSV`
- тесты должны запускать с бенчмарком, несмотря на кажущееся поначалу неудобство. 

## Результаты

В результате проделанной оптимизации наконец удалось обработать файл с данными в пределах отведенного времени.

####Результаты теста
|                           |                        |                                  | 
|---------------------------|------------------------|----------------------------------| 
| Количество юзеров в файле | до оптимизаций, с      | После оптимизаций, с             | 
| 1                         | 0.00044304000039119273 |        не измерялось             | 
| 5                         | 0.0032413640001323074  |        не измерялось             | 
| 10                        | 0.0089597149999463     |  0.0005151439982000738           | 
| 50                        | 0.20008935000078054    |  0.000861273001646623            | 
| 100                       | 0.8346927900001901     |  0.001767244997608941            | 
| 500                       | 30.74916015999952      |  0.0055185169985634275           | 
| large                     | ???                    |  26.556534313996963              | 



## Защита от регрессии производительности
Для защиты от потери достигнутого прогресса при дальнейших изменениях программы была написана спека с использованием 'rspec-benchmark', гарантирующая обработку большого файла за время меньшее, чем 30 секунд.

