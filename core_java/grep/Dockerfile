FROM eclipse-temurin:8-jre-alpine

WORKDIR /usr/local/app/grep

COPY target/grep*.jar lib/grep.jar

ENTRYPOINT ["java","-jar","lib/grep.jar"]
