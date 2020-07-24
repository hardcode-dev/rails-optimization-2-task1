require_relative 'task-1'
require 'ruby-progressbar'

parts = 2
progressbar = ProgressBar.create(total: parts, format: '%a, %J, %E %B')

progressbar.increment
work
progressbar.increment

