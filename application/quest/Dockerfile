FROM node:14

WORKDIR /usr/src/app

COPY . .

RUN npm install

EXPOSE 3000
CMD [ "node", "000.js" ]

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
