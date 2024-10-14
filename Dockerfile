#frontend için dockerfile

FROM node:18-alpine

WORKDIR /app

COPY . .

COPY package*.json ./

RUN npm install

RUN npm run build

FROM nginx:alpine

COPY --from=0 /app/build /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]