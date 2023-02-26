FROM golang:latest as builder

WORKDIR /app

COPY . .

RUN go mod tidy

WORKDIR /app/cmd

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/cmd .

ENTRYPOINT ["./main"]

CMD ["start","-a"]