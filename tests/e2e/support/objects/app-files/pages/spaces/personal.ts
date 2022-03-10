import { Sidebar as BaseSidebar } from '../../shared/sidebar'
import { Resource as BaseResource } from '../../shared/resource'
import { Page } from 'playwright'

class Sidebar extends BaseSidebar {}
class Resource extends BaseResource {}

export class Personal {
  #page: Page

  sidebar: Sidebar
  resource: Resource

  constructor({ page }: { page: Page }) {
    this.#page = page

    this.sidebar = new Sidebar({ page })
    this.resource = new Resource({ page })
  }

  // toDo: find better naming, e.g. goTo like playwright??!!
  async navigate(): Promise<void> {
    await this.#page.locator('//a[@data-nav-name="files-spaces-personal-home"]').click()
  }
}
