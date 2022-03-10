import { Download, Page } from 'playwright'
import {
  createResource,
  createResourceArgs,
  createResourceLink,
  createResourceLinkArgs,
  downloadResources,
  downloadResourcesArgs,
  moveOrCopyResource,
  moveOrCopyResourceArgs,
  shareResource,
  shareResourceArgs,
  uploadResource,
  uploadResourceArgs
} from './actions'

export abstract class Resource {
  #page: Page

  constructor({ page }: { page: Page }) {
    this.#page = page
  }

  async create(args: Omit<createResourceArgs, 'page'>): Promise<void> {
    const startUrl = this.#page.url()
    await createResource({ page: this.#page, ...args })
    await this.#page.goto(startUrl)
    await this.#page.waitForSelector('.files-table')
  }

  async upload(args: Omit<uploadResourceArgs, 'page'>): Promise<void> {
    const startUrl = this.#page.url()
    await uploadResource({ page: this.#page, ...args })
    await this.#page.goto(startUrl)
    // why? o_O
    await this.#page.locator('body').click()
  }

  async download(args: Omit<downloadResourcesArgs, 'page'>): Promise<Download[]> {
    const startUrl = this.#page.url()
    const downloads = await downloadResources({ page: this.#page, ...args })
    await this.#page.goto(startUrl)

    return downloads
  }

  async share(args: Omit<shareResourceArgs, 'page'>): Promise<void> {
    const startUrl = this.#page.url()
    await shareResource({ page: this.#page, ...args })
    await this.#page.goto(startUrl)
    // why? o_O
    await this.#page.locator('body').click()
  }

  async rename({ name, type }: { name: string; type: 'folder' }): Promise<void> {}

  async copy(args: Omit<moveOrCopyResourceArgs, 'page' | 'action'>): Promise<void> {
    const startUrl = this.#page.url()
    await moveOrCopyResource({ page: this.#page, action: 'copy', ...args })
    await this.#page.goto(startUrl)
  }

  async move(args: Omit<moveOrCopyResourceArgs, 'page' | 'action'>): Promise<void> {
    const startUrl = this.#page.url()
    await moveOrCopyResource({ page: this.#page, action: 'move', ...args })
    await this.#page.goto(startUrl)
  }

  async delete({ name, type }: { name: string; type: 'folder' }): Promise<void> {}

  async open({ name, type }: { name: string; type: 'folder' }): Promise<void> {}

  async(args: Omit<createResourceLinkArgs, 'page'>): Promise<void> {
    const startUrl = this.#page.url()
    await createResourceLink({ page: this.#page, ...args })
    await this.#page.goto(startUrl)
  }
}
