# FROM maven:3.9-eclipse-temurin-17 AS build
FROM docker.m.daocloud.io/library/maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# 复制pom.xml和源码
COPY pom.xml .
COPY seckill-common/pom.xml seckill-common/
COPY seckill-gateway/pom.xml seckill-gateway/
COPY seckill-user-service/pom.xml seckill-user-service/
COPY seckill-product-service/pom.xml seckill-product-service/
COPY seckill-order-service/pom.xml seckill-order-service/
COPY seckill-seckill-service/pom.xml seckill-seckill-service/

COPY seckill-common/src seckill-common/src
COPY seckill-gateway/src seckill-gateway/src
COPY seckill-user-service/src seckill-user-service/src
COPY seckill-product-service/src seckill-product-service/src
COPY seckill-order-service/src seckill-order-service/src
COPY seckill-seckill-service/src seckill-seckill-service/src

# 构建Gateway
RUN mvn -f seckill-gateway/pom.xml clean package -DskipTests

# FROM eclipse-temurin:17-jre-alpine
FROM docker.m.daocloud.io/library/eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=build /app/seckill-gateway/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
