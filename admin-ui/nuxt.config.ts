import { joinURL } from "ufo";

const API_URL = process.env.API_URL

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  devServer: {
    port: 5073,
  },
  routeRules: {
    "/api/**": API_URL
      ? {
          proxy: joinURL(API_URL, "/**"),
        }
      : {},
  },
});
