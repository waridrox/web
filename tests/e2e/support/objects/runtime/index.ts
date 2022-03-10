import { Page } from 'playwright'
import { Application } from './application'
import { Session } from './session'

export class Runtime {
  application: Application
  session: Session

  constructor({ page }: { page: Page }) {
    this.application = new Application({ page })
    // toDo: implement or o_O
    this.session = new Session({ page })
  }
}
