## Structure Demo

**A simple structure to implement separation of front-end and backend with mono repo. Deploy on docker and update by rolling deployment.**

Base on ***ASP.NET core 8.0*** and ***Nuxt 3***

* * *

### Quick Start for Develop

#### API (ASP.NET core 8.0)

- Command

  ```sh
  cd api-demo
  dotnet run
  ```

- Docker

  ```sh
  docker-compose up -d dev-api
  ```

#### UI (Nuxt 3)

> Or you can modify `API_URL` to any api server

- Command

  ```sh
  yarn install
  yarn admin dev
  ```

- Docker

  ```sh
  docker-compose up -d dev-admin
  ```


### Deployment

```sh
sh deploy.sh [admin|backend]
```

