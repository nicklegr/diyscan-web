FROM ruby:2.7.1

ENV TZ Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# スクリプトに変更があっても、bundle installをキャッシュさせる
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --deployment --without=test --jobs 4

COPY . /usr/src/app

EXPOSE 80
