import { FolderLoader, FolderLoaderTask, TaskContext } from '../folder'
import Router from 'vue-router'
import { useTask } from 'vue-concurrency'
import { isLocationSpacesActive } from '../../router'
import { clientService } from 'web-pkg/src/services'
import { buildResource, buildSpace, buildWebDavSpacesPath } from '../../helpers/resources'

export class FolderLoaderProject implements FolderLoader {
  public isEnabled(router: Router): boolean {
    return isLocationSpacesActive(router, 'files-spaces-project')
  }

  public getTask(context: TaskContext): FolderLoaderTask {
    return useTask(function* (signal1, signal2, ref, sameRoute, path = null) {
      const router = context.router
      const store = context.store

      const graphClient = clientService.graphAuthenticated(
        store.getters.configuration.server,
        store.getters.getToken
      )

      ref.CLEAR_CURRENT_FILES_LIST()
      const spaceId = router.currentRoute.params.spaceId
      const graphResponse = yield graphClient.drives.getDrive(spaceId)

      if (!graphResponse.data) {
        return
      }

      ref.space = buildSpace(graphResponse.data)

      const webDavResponse = yield ref.$client.files.list(
        buildWebDavSpacesPath(ref.$route.params.spaceId, path || '')
      )

      let resources = []
      if (!path) {
        // space front page -> use space as current folder
        resources.push(ref.space)

        const webDavResources = webDavResponse.map(buildResource)
        webDavResources.shift() // Remove webdav entry for the space itself
        resources = resources.concat(webDavResources)
      } else {
        resources = webDavResponse.map(buildResource)
      }

      const currentFolder = resources.shift()

      ref.LOAD_FILES({
        currentFolder,
        files: resources
      })
      ref.loadIndicators({
        client: ref.$client,
        currentFolder: currentFolder?.path
      })
    })
  }
}
