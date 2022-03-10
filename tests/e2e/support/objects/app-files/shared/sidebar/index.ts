import { Page } from 'playwright'
import { closeSidebar, openSidebarPanel } from './actions'

export abstract class Sidebar {
  #page: Page

  constructor({ page }: { page: Page }) {
    this.#page = page
  }

  protected async open({ name }: { name: string }): Promise<void> {
    await openSidebarPanel({ page: this.#page, name })
  }

  protected async close(): Promise<void> {
    await closeSidebar({ page: this.#page })
  }

  protected async openPanel({ name }: { name: string }): Promise<void> {
    await openSidebarPanel({ page: this.#page, name })
  }
}
