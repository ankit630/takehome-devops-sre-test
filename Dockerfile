FROM node:17.3-alpine as BUILD_IMAGE

# Using the Node Env as production
ENV NODE_ENV=production

# Use working directory as /app
workdir /app

# Env variable
ENV NEXT_PUBLIC_APP_VERSION=v1.2.2

# Copy the package .json and package-lock.json
COPY ["package.json", "package-lock.json", "./"]

#Run NPM install
RUN npm install --production 

COPY . ./app

RUN mkdir pages

RUN npm run build

RUN rm -rf /app/node_modules/@sentry
RUN rm -rf /app/node_modules/es-abstract
RUN rm -rf /app/node_modules/terser
RUN rm -rf /app/node_modules/terser-webpack-plugin
RUN rm -rf /app/node_modules/caniuse-lite
RUN rm -rf /app/node_modules/dayjs
RUN rm -rf /app/node_modules/ajv

### Multi stage build for optimizing the size of docker image

# Image
FROM node:17.3-alpine

# Add a user with userid 8566 and name vagrant
RUN adduser -D -g '' -u 1004 vagrant
#
# Run container as vagrant
USER vagrant

# Use working directory as /app
workdir /app

# copy from build image
COPY --from=BUILD_IMAGE /app/node_modules /app/node_modules
COPY --from=BUILD_IMAGE /app/.next /app/.next
COPY . /app

# Application Port
EXPOSE 3000

# Start the Application
CMD ["npm","start"]
