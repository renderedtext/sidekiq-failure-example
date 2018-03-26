FROM ruby:2.3-slim

RUN gem install sidekiq --no-ri --no-doc

ADD app.rb app.rb
ADD enqueue.rb enqueue.rb

CMD ["sidekiq", "-r", "./app.rb"]
