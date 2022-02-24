import { DataTable } from '@cucumber/cucumber'
import { PublicLinkPage } from '../../page/publicLinkPage'
import { filesCta } from '../../cta'

export const checkResourcesExistence = async ({
  actionType,
  stepTable,
  resourceType = 'public'
}: {
  actionType: string
  stepTable: DataTable
  resourceType?: string
}): Promise<void> => {
  const publicLinkPage = new PublicLinkPage()
  actionType = actionType.trim()

  const files = stepTable.raw().map((f) => f[0])
  for (const file of files) {
    const resourceExist = await publicLinkPage.resourceExists({
      resourceType,
      name: file
    })
    filesCta.resourceExistenceErrorMessage(actionType, resourceExist, file)
  }
}
