import { Download, Page } from 'playwright'
import { resourceExists, waitForResources } from './utils'
import path from 'path'
import { File, User } from '../../../../types'
import { openSidebarPanel, openSidebar, closeSidebar } from '../sidebar/actions'
import { getActualExpiryDate } from '../../../../utils/datePicker'
import util from 'util'

export const clickResource = async ({
  page,
  path
}: {
  page: Page
  path: string
}): Promise<void> => {
  const paths = path.split('/')
  for (const name of paths) {
    await page.locator(`[data-test-resource-name="${name}"]`).click()
  }
}

/**/

export type createResourceArgs = {
  page: Page
  name: string
  type: 'folder'
}

export const createResource = async (args: createResourceArgs): Promise<void> => {
  const { page, name } = args
  const paths = name.split('/')

  for (const folderName of paths) {
    const folderExists = await resourceExists({
      page: page,
      name: folderName
    })

    if (!folderExists) {
      await page.locator('#new-file-menu-btn').click()
      await page.locator('#new-folder-btn').click()
      await page.locator('.oc-modal input').fill(folderName)
      await Promise.all([
        page.waitForResponse(
          (resp) => resp.status() === 201 && resp.request().method() === 'MKCOL'
        ),
        page.locator('.oc-modal-body-actions-confirm').click()
      ])
    }

    await clickResource({ page, path: folderName })
  }
}

/**/

export type uploadResourceArgs = {
  page: Page
  resources: File[]
  to?: string
  createVersion?: boolean
}

export const uploadResource = async (args: uploadResourceArgs): Promise<void> => {
  const { page, resources, to, createVersion } = args

  if (to) {
    await clickResource({ page: page, path: to })
  }

  await page.locator('#upload-menu-btn').click()
  await page.locator('#fileUploadInput').setInputFiles(resources.map((file) => file.path))

  if (createVersion) {
    const fileName = resources.map((file) => path.basename(file.name))
    await Promise.all([
      page.waitForResponse((resp) => resp.url().endsWith(fileName[0]) && resp.status() === 204),
      page.locator('.oc-modal-body-actions-confirm').click()
    ])
  }

  await waitForResources({
    page: page,
    names: resources.map((file) => path.basename(file.name))
  })
}

/**/

export type shareResourceArgs = {
  page: Page
  folder: string
  users: User[]
  role: string
  via: 'SIDEBAR_PANEL' | 'QUICK_ACTION'
}

export const shareResource = async (args: shareResourceArgs): Promise<void> => {
  const { page, folder, users, role, via } = args
  const folderPaths = folder.split('/')
  const folderName = folderPaths.pop()

  if (folderPaths.length) {
    await clickResource({ page: page, path: folderPaths.join('/') })
  }

  switch (via) {
    case 'QUICK_ACTION':
      await page
        .locator(
          `//*[@data-test-resource-name="${folderName}"]/ancestor::tr//button[contains(@class, "files-quick-action-collaborators")]`
        )
        .click()
      break

    case 'SIDEBAR_PANEL':
      await openSidebar({ page: page, resource: folderName })
      await openSidebarPanel({ page: page, name: 'sharing' })
      break
  }

  for (const user of users) {
    const shareInputLocator = page.locator('#files-share-invite-input')
    await Promise.all([
      page.waitForResponse((resp) => resp.url().includes('sharees') && resp.status() === 200),
      shareInputLocator.fill(user.id)
    ])
    await shareInputLocator.focus()
    await page.waitForSelector('.vs--open')
    await page.locator('#files-share-invite-input').press('Enter')

    await page.locator('//*[@id="files-collaborators-role-button-new"]').click()
    await page.locator(`//*[@id="files-role-${role}"]`).click()
  }

  await Promise.all([
    page.waitForResponse(
      (resp) =>
        resp.url().endsWith('shares') && resp.status() === 200 && resp.request().method() === 'POST'
    ),
    page.locator('#new-collaborators-form-create-button').click()
  ])

  await closeSidebar({ page: page })
}

/**/

export type downloadResourcesArgs = {
  page: Page
  names: string[]
  folder: string
}

export const downloadResources = async (args: downloadResourcesArgs): Promise<Download[]> => {
  const { page, names, folder } = args
  const downloads = []

  if (folder) {
    await clickResource({ page, path: folder })
  }

  for (const name of names) {
    await openSidebar({ page: page, resource: name })
    await openSidebarPanel({ page: page, name: 'actions' })

    const [download] = await Promise.all([
      page.waitForEvent('download'),
      page.locator('#oc-files-actions-sidebar .oc-files-actions-download-file-trigger').click()
    ])

    await closeSidebar({ page: page })

    downloads.push(download)
  }

  return downloads
}

/**/

export type createResourceLinkArgs = {
  page: Page
  resource: string
  name: string
  role: string
  dateOfExpiration: string
  password: string
  via: 'SIDEBAR_PANEL' | 'QUICK_ACTION'
}

export const createResourceLink = async (args: createResourceLinkArgs): Promise<void> => {
  const { page, resource, name, role, dateOfExpiration, password, via } = args
  const resourcePaths = resource.split('/')
  const resourceName = resourcePaths.pop()
  if (resourcePaths.length) {
    await clickResource({ page: page, path: resourcePaths.join('/') })
  }

  switch (via) {
    case 'QUICK_ACTION':
      await page
        .locator(
          util.format(
            `//*[@data-test-resource-name="%s"]/ancestor::tr//button[contains(@class, "files-quick-action-collaborators")]`,
            resourceName
          )
        )
        .click()
      break

    case 'SIDEBAR_PANEL':
      await openSidebar({ page: page, resource: resourceName })
      await openSidebarPanel({ page: page, name: 'links' })
      break
  }
  await page.locator('#files-file-link-add').click()

  if (name) {
    await page.locator('#oc-files-file-link-name').fill(name)
  }

  if (role) {
    await page.locator('#files-file-link-role-button').click()
    await page.locator(util.format(`//span[@id="files-role-%s"]`, role)).click()
  }

  if (dateOfExpiration) {
    const newExpiryDate = getActualExpiryDate(
      dateOfExpiration.toLowerCase().match(/[dayrmonthwek]+/)[0],
      dateOfExpiration
    )

    await page.locator('#oc-files-file-link-expire-date').evaluate(
      (datePicker: any, { newExpiryDate }): any => {
        datePicker.__vue__.updateValue(newExpiryDate)
      },
      { newExpiryDate }
    )
  }

  if (password) {
    await page.locator('#oc-files-file-link-password').fill(password)
  }

  await page.locator('#oc-files-file-link-create').click()
}

/**/

export type moveOrCopyResourceArgs = {
  page: Page
  resource: string
  newLocation: string
  action: 'copy' | 'move'
}

export const moveOrCopyResource = async (args: moveOrCopyResourceArgs): Promise<void> => {
  const { page, resource, newLocation, action } = args
  const { dir: resourceDir, base: resourceBase } = path.parse(resource)

  if (resourceDir) {
    await clickResource({ page: page, path: resourceDir })
  }

  await page.locator(`//*[@data-test-resource-name="${resourceBase}"]`).click({ button: 'right' })
  await page.locator(`.oc-files-actions-${action}-trigger`).first().click()
  await page.locator('//nav[contains(@class, "oc-breadcrumb")]/ol/li[1]/a').click()

  if (newLocation !== 'Personal') {
    await clickResource({ page: page, path: newLocation })
  }

  await Promise.all([
    page.waitForResponse(
      (resp) =>
        resp.url().endsWith(resourceBase) &&
        resp.status() === 201 &&
        resp.request().method() === action.toUpperCase()
    ),
    page.locator('#location-picker-btn-confirm').click()
  ])

  await waitForResources({
    page,
    names: [resourceBase]
  })
}
