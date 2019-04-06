# Notepad

Notepad is a console application which allows you to take notes with text, save useful links with a small description, and 
also save tasks for further execution.

## Installing and using the program

1. The console application was created on the __Ruby 2.5.1__ .
You need to install [Ruby interpreter](https://www.ruby-lang.org/en/news/2018/03/28/ruby-2-5-1-released) 
in order to work with that.

2. The console application uses SQLite and gem sqlite3. You need to install these components as follows:
```
sudo apt-get install  sqlite3
gem install sqlite3
```

3. The program uses such a library (gem) as __i18n__. Ensure that the library manager __bundler__ is installed:
    * Input in the __cmd__ or __terminal__ the following command:
      ```
      gem install bundler
      ```
    * After installing the library manager, input the next command in order to make sure that it was installed:
      ```
      bundler -v
      ```
    * Input the next command for installing the necessary gems before running program:
      ```
      bundle install
      ```

4. Commands for running application from the console:
    * Adding a new record:
      ```
      ruby new_post.rb
      ```
    * Reading previous records:
      ```
      ruby read.rb [options]
      ```
    * Calling help:
      ```
      ruby read.rb -h
      ```
      Available options for reading:
      ```
      -h                           available options
      --type POST_TYPE             what type of posts to show (by default any)
      --id POST_ID                 if id is specified - shows in detail only this post
      --limit NUMBER               how many last posts to show (by default all)
      ```
    * You can run application using a necessary locale. In order to do it, just input the following commands:
      ```
      ruby new_post.rb [locale]
      ruby read.rb [locale] [options]
      ruby read.rb [locale] -h
      ```
      where `[locale]` is a locale key. There are two locale keys in the program such as `en` and `ru`.
    
## Types of records

Notepad allows you to save three types of records:
* Memo - your text notes
* Task - your everyday tasks
* Link - links to your favourite sites

## Storage records

Records are saved to the `notepad.sqlite3` database file in the root directory of the application. If there is no file, 
it will be generated upon the first running.

## Demo

You can watch a demo version of the application at the [link](https://asciinema.org/a/fQyKVAbsvvtbfNUSqKQjEYwNm).

## Author

**Kirill Ilyin**, study project from [goodprogrammer.ru](https://goodprogrammer.ru/)
