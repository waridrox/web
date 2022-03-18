## GSoC Task Evaluation Test for [project](https://hepsoftwarefoundation.org/gsoc/2022/proposal_CERNBOXimageExplorer.html) referencing [task](https://github.com/elizavetaRa/GSoC-Evaluation-Test)

_Contact_:
* Name: Mohammad Warid
* Email: mohdwarid4@gmail.com
* Github: https://github.com/waridrox

___
To get started - 
Bash 1:
```bash
git clone -b task https://github.com/waridrox/web.git
cd web
yarn && yarn build:w
```

Bash 2:
```bash
cd web
docker compose up ocis
```

Project can be accessed at `https://host.docker.internal:9200/`

`Commit Hash: bd0078be`

### **Task 1: Install OCIS & local web**
This task was pretty straightforward, but the application wasn't responding on https://localhost:9200 as directed in the [developer docs](https://owncloud.dev/clients/web/backend-ocis/). Instead, https://host.docker.internal:9200/ and some help from the community at https://talk.owncloud.com/channel/ocis did the trick.

___

### **Task 2: Image filter**
This task can branch into different variations: 

**CASE 1:** If we want to keep the shared folder intact after applying the image filter. [_Demo_ ](https://drive.google.com/file/d/1ysiNzkk7Cd0soOGvVkMkP4XUIpnH1le8/view?usp=sharing)

_This is achieved by persisting the folders with the `isFolder` bool value or checking if the mime type of the file is of the `image` type_

```javascript
if (state.areImageFilesShown) {
       files = files.filter(
        (file) => file.isFolder || file.mimeType.startsWith('image/')
      )
    }
```

**CASE 2:** If we do not want to keep the shared folder intact. This could make more sense from the perspective of the project description (https://hepsoftwarefoundation.org/gsoc/2022/proposal_CERNBOXimageExplorer.html) wherein we just need to deal with different image formats. [_Demo_](https://drive.google.com/file/d/1IRjtACU8bsOTrxGfzLEv8Kx2Fy3nmvpM/view?usp=sharing)
```javascript
if (state.areImageFilesShown) {
  files = files.filter((file) => file.mimeType !== undefined && file.mimeType.startsWith('image/'))
}
// OR
if (state.areImageFilesShown) {
      files = files.filter(
        (file) =>
          file.extension === 'jpg' ||
          file.extension === 'JPG' ||
          file.extension === 'ico' ||
          file.extension === 'jpeg' ||
          file.extension === 'png' ||
          file.extension === 'gif' ||
          file.extension === 'webp' ||
          file.extension === 'svg' ||
          file.extension === 'webp'
      )
    }
// ANY ONE OF THE APPROACHES CAN BE USED
```
_Here the implementation from CASE 1 doesn't work since that also has folders which are of `mimeType = undefined`. Thus either we need to filter out the files which have `mimeType = undefined` first and then filter out those mimeTypes that are of the type `image/` from the new array of file objects, or we can check for the file types individually as above_

___

### **Task 3: Control the image filter from the interface**
For this task, the most suitable approach could be to simply add a toggle switch like the one for displaying the hidden files. This way, the UI is not hindered with new buttons or approaches that the users are unaware of. However, if the image gallery application has to be implemented, a picture icon could be displayed if it detects any images present in the list of files. And when the user clicks on the image icon, the gallery functionality can take effect. 


To filter the images on the toggle, we can add a new state variable in the vuex store, `areImageFilesShown` and set its default state to `false` initially. If the user clicks the toggle switch, the state of this variable changes to true, which triggers the images filter function.

In `state.js` under `packages/web-app-files/src/store/state.js`:
```javascript
areImageFilesShown: false
```

Adding a toggle-switch component under `packages/web-app-files/src/components/AppBar/ViewOptions.vue` below the `hidden-files` option: 
```javascript
<oc-switch
  v-model="imageFilesShownModel"
  data-testid="files-switch-image-files"
  :label="$gettext('Show image files')"
/>
```

Then changing image files visibility under `packages/web-app-files/src/store/mutations.js` and persisting state to `localStorage`:
```javascript
SET_IMAGE_FILES_VISIBILITY(state, value) {
    state.areImageFilesShown = value

    window.localStorage.setItem('oc_imageFilesShown', value)
}
```


___
### **Task 4: Bonus**
Since we are already making use of the state variables and altering the files array in Task 3 through one of the `getters` function, we have already achieved Task 4.

___
### **Task 5: Description**
Coding decisions have been covered through Task explanations 1 to 4

To keep the UX intact with the current implementation, I have placed the widget in the same place as the toggle switch for hidden files in the interface. It is recognisable since the toggle switch changes its colour in its active state, plus the files list is filtered only by images. To further increase the UX, one can add a notification message using the `OcNotificationMessage` ownCloud Design System component stating "Images filter applied!". 

<img width="560" alt="Screenshot 2022-03-18 at 1 30 39 AM" src="https://user-images.githubusercontent.com/58583793/158987559-766df83e-5c19-49e9-be43-6095c8bb85d8.png">



Another approach could be the inclusion of a new image gallery component that can flash once or twice if it detects that image files are present in the files list. When the user clicks the icon, the gallery application should fire up.

Sample: <img width="1280" alt="sample" src="https://user-images.githubusercontent.com/58583793/158958242-d30302b8-c9ad-4c8e-8bdd-5aaddfe6b8b1.png">
