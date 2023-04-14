FROM swift:latest as builder
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y libjavascriptcoregtk-4.0-dev \
    && pkg-config --libs javascriptcoregtk-4.0

RUN swift build --product apollo-ios-cli -c release

CMD ["/app/.build/release/apollo-ios-cli"]
