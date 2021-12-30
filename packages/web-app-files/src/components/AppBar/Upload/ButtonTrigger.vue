<template>
  <div class="oc-mr-s">
    <oc-button @click="triggerUpload">
      <oc-icon name="cloud_upload" />
      <span id="files-folder-upload-button" v-translate>Upload</span>
    </oc-button>
    <input
      id="my-file-input"
      ref="input"
      type="file"
      multiple
      aria-labelledby="files-folder-upload-button"
      tabindex="-1"
    />
  </div>
</template>

<script>
export default {
  methods: {
    triggerUpload() {
      this.$refs.input.click()
    }
  }
}
</script>

<style scoped="true">
#my-file-input {
  position: absolute;
  left: -99999px;
}
</style>
