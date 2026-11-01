FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY mvnw .
COPY .mvn/ .mvn/
COPY pom.xml .

RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY src/ src/
RUN ./mvnw clean package -DskipTests -B

RUN set -eux; \
    JAR_FILE="$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.original' | head -n 1)"; \
    test -n "$JAR_FILE"; \
    cp "$JAR_FILE" application.jar


FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /application

RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=builder --chown=spring:spring /app/application.jar application.jar

ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

EXPOSE 8080

HEALTHCHECK --interval=30s \
    --timeout=5s \
    --start-period=60s \
    --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/actuator/health || exit 1

USER spring:spring

ENTRYPOINT ["java", "-jar", "application.jar"]
