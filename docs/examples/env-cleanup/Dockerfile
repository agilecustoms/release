FROM bellsoft/liberica-openjdk-alpine:23 AS base
# ...
ENTRYPOINT [ "java", "-cp", "/BOOT-INF/lib/*:${APP_DIR}", "com.amazonaws.services.lambda.runtime.api.client.AWSLambda" ]
CMD [ "com.agilecustoms.cleanup.Lambda::handleRequest" ]
