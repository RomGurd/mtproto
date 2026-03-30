FROM ubuntu:resolute-20260312 AS builder

RUN apt-get update && \
    apt-get install -y git curl build-essential libssl-dev zlib1g-dev

RUN git clone https://github.com/TelegramMessenger/MTProxy /MTProxy

WORKDIR /MTProxy
RUN make 


FROM ubuntu:resolute-20260312

RUN apt-get update && \
    apt-get install -y libssl-dev zlib1g curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /MTProxy/objs/bin/mtproto-proxy .

COPY run.sh .
RUN chmod +x run.sh

EXPOSE 8888 443

CMD ["./run.sh"]