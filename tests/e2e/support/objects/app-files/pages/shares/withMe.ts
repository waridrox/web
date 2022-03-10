import { Page } from 'playwright'
import path from 'path'
import { clickResource } from '../../shared/resource/actions'

class Shares {
  #page: Page

  constructor({ page }: { page: Page }) {
    this.#page = page
  }

  async accept({ name }: { name: string }): Promise<void> {
    const startUrl = this.#page.url()
    await this.#page
      .locator(
        `//*[@data-test-resource-name="${name}"]/ancestor::tr//button[contains(@class, "file-row-share-status-accept")]`
      )
      .click()
    await this.#page.waitForResponse(
      (resp) => resp.url().includes('shares') && resp.status() === 200
    )

    /**
     * the next part exists to trick the backend, in some cases accepting a share can take longer in the backend.
     * therefore we're waiting for the resource to exist, navigate into it (if resource is a folder) to be really sure its there and then come back.
     * If the logic is needed more often it can be refactored into a shared helper.
     */
    await this.#page
      .locator(`#files-shared-with-me-shares-table [data-test-resource-name="${name}"]`)
      .waitFor()

    if (!path.extname(name)) {
      await clickResource({ page: this.#page, path: name })
      await this.#page.goto(startUrl)
    }
  }
}

export class WithMe {
  #page: Page

  shares: Shares

  constructor({ page }: { page: Page }) {
    this.#page = page

    this.shares = new Shares({ page })
  }

  async navigate(): Promise<void> {
    await this.#page.locator('//a[@data-nav-name="files-shares-with-me"]').click()
  }
}
