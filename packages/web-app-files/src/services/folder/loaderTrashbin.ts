import { FolderLoader, FolderLoaderTask, TaskContext } from '../folder'
import Router from 'vue-router'
import { useTask } from 'vue-concurrency'
import { DavProperties } from 'web-pkg/src/constants'
import { isLocationTrashActive } from '../../router'
import {
  buildDeletedResource,
  buildResource,
  buildWebDavFilesTrashPath,
  buildWebDavSpacesTrashPath
} from '../../helpers/resources'

export class FolderLoaderTrashbin implements FolderLoader {
  public isEnabled(router: Router): boolean {
    return (
      isLocationTrashActive(router, 'files-trash-personal') ||
      isLocationTrashActive(router, 'files-trash-spaces-project')
    )
  }

  public getTask(context: TaskContext): FolderLoaderTask {
    return useTask(function* (signal1, signal2, ref) {
      ref.CLEAR_CURRENT_FILES_LIST()

      const path = isLocationTrashActive(context.router, 'files-trash-spaces-project')
        ? buildWebDavSpacesTrashPath(context.route.params.spaceId)
        : buildWebDavFilesTrashPath(context.store.getters.user.id)
      const resources = yield ref.$client.fileTrash.list(path, '1', DavProperties.Trashbin)

      ref.LOAD_FILES({
        currentFolder: buildResource(resources[0]),
        files: resources.slice(1).map(buildDeletedResource)
      })
      ref.refreshFileListHeaderPosition()
    })
  }
}
