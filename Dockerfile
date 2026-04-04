
# ================================
# Stage 1: Build the application
# ================================
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build

# Copy pom.xml first (for dependency caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build jar (skip tests if you want faster build)
RUN mvn clean package -DskipTests


# ================================
# Stage 2: Run the application
# ================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the jar from build stage
COPY --from=build /build/target/*.jar app.jar

# Expose Spring Boot port
EXPOSE 8085

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
