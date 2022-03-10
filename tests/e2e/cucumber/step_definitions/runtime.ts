import { When } from '@cucumber/cucumber'
import { World } from '../environment'
import { Runtime } from '../../support/objects/runtime'

When(
  '{string} opens the {string} app',
  async function (this: World, stepUser: string, stepApp: string): Promise<void> {
    const { page } = this.actorsEnvironment.getActor({ id: stepUser })
    // const runtimePage = new RuntimePage({ actor })
    const runtime = new Runtime({ page })

    // await runtimePage.navigateToApp({ name: stepApp })
    await runtime.application.open({ name: stepApp })
  }
)
