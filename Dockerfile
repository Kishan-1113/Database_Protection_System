
# ============================================
# Stage 1: Build the Spring Boot application
# ============================================
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Maven wrapper and dependency metadata
COPY mvnw .
COPY .mvn/ .mvn/
COPY pom.xml .

# Ensure Maven wrapper is executable
RUN chmod +x mvnw

# Download dependencies separately for Docker layer caching
RUN ./mvnw dependency:go-offline -B

# Copy application source
COPY src/ src/

# Build executable Spring Boot JAR
RUN ./mvnw clean package -DskipTests -B

# Extract Spring Boot layers
RUN set -eux; \
    JAR_FILE="$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.original' | head -n 1)"; \
    test -n "$JAR_FILE"; \
    cp "$JAR_FILE" application.jar; \
    java -Djarmode=tools -jar application.jar extract \
    --layers --destination extracted


# ============================================
# Stage 2: Production runtime
# ============================================
FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /application

# Create a non-root user
RUN addgroup -S spring && adduser -S spring -G spring

# Copy Spring Boot layers separately
COPY --from=builder --chown=spring:spring /app/extracted/dependencies/ ./
COPY --from=builder --chown=spring:spring /app/extracted/spring-boot-loader/ ./
COPY --from=builder --chown=spring:spring /app/extracted/snapshot-dependencies/ ./
COPY --from=builder --chown=spring:spring /app/extracted/application/ ./

# Runtime configuration
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

# Application port
EXPOSE 8080

# Health check (requires Spring Boot Actuator), change to actual server path before deployment 
HEALTHCHECK --interval=30s \
    --timeout=5s \
    --start-period=60s \
    --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/actuator/health || exit 1

# Run as non-root
USER spring:spring

# Start application
ENTRYPOINT ["java", "-jar", "application.jar"]
