import React from "react"
import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'

createInertiaApp({
  resolve: async (name) => {
    const module = await import(`./pages/${name}.jsx`)
    return module
  },
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
