FROM ruby:2.6-stretch

# Required to bind to 0.0.0.0 so service is reachable outside of the container
ENV RACK_ENV=production
EXPOSE 4567

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
RUN bundle install

COPY . /app
CMD ["ruby", "hello.rb"]
