FROM mangeshabnave/spring-maven as build
WORKDIR /code
COPY . .
RUN mvn package

FROM tomcat
COPY --from=build /code/target/*.war /usr/local/tomcat/webapps/
