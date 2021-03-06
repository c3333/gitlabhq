<script>
/* eslint-disable vue/no-v-html */
import { mapState, mapActions, mapGetters } from 'vuex';
import { GlButton, GlFormInput, GlFormGroup } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import MarkdownField from '~/vue_shared/components/markdown/field.vue';
import { BACK_URL_PARAM } from '~/releases/constants';
import { getParameterByName } from '~/lib/utils/common_utils';
import AssetLinksForm from './asset_links_form.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import MilestoneCombobox from '~/milestones/project_milestone_combobox.vue';
import TagField from './tag_field.vue';

export default {
  name: 'ReleaseEditNewApp',
  components: {
    GlFormInput,
    GlFormGroup,
    GlButton,
    MarkdownField,
    AssetLinksForm,
    MilestoneCombobox,
    TagField,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapState('detail', [
      'isFetchingRelease',
      'isUpdatingRelease',
      'fetchError',
      'markdownDocsPath',
      'markdownPreviewPath',
      'releasesPagePath',
      'updateReleaseApiDocsPath',
      'release',
      'newMilestonePath',
      'manageMilestonesPath',
      'projectId',
    ]),
    ...mapGetters('detail', ['isValid', 'isExistingRelease']),
    showForm() {
      return Boolean(!this.isFetchingRelease && !this.fetchError && this.release);
    },
    subtitleText() {
      return sprintf(
        __(
          'Releases are based on Git tags. We recommend tags that use semantic versioning, for example %{codeStart}v1.0%{codeEnd}, %{codeStart}v2.0-pre%{codeEnd}.',
        ),
        {
          codeStart: '<code>',
          codeEnd: '</code>',
        },
        false,
      );
    },
    releaseTitle: {
      get() {
        return this.$store.state.detail.release.name;
      },
      set(title) {
        this.updateReleaseTitle(title);
      },
    },
    releaseNotes: {
      get() {
        return this.$store.state.detail.release.description;
      },
      set(notes) {
        this.updateReleaseNotes(notes);
      },
    },
    releaseMilestones: {
      get() {
        return this.$store.state.detail.release.milestones;
      },
      set(milestones) {
        this.updateReleaseMilestones(milestones);
      },
    },
    cancelPath() {
      return getParameterByName(BACK_URL_PARAM) || this.releasesPagePath;
    },
    showAssetLinksForm() {
      return this.glFeatures.releaseAssetLinkEditing;
    },
    saveButtonLabel() {
      return this.isExistingRelease ? __('Save changes') : __('Create release');
    },
    isFormSubmissionDisabled() {
      return this.isUpdatingRelease || !this.isValid;
    },
    milestoneComboboxExtraLinks() {
      return [
        {
          text: __('Create new'),
          url: this.newMilestonePath,
        },
        {
          text: __('Manage milestones'),
          url: this.manageMilestonesPath,
        },
      ];
    },
  },
  mounted() {
    // eslint-disable-next-line promise/catch-or-return
    this.initializeRelease().then(() => {
      // Focus the first non-disabled input element
      this.$el.querySelector('input:enabled').focus();
    });
  },
  methods: {
    ...mapActions('detail', [
      'initializeRelease',
      'saveRelease',
      'updateReleaseTitle',
      'updateReleaseNotes',
      'updateReleaseMilestones',
    ]),
    submitForm() {
      if (!this.isFormSubmissionDisabled) {
        this.saveRelease();
      }
    },
  },
};
</script>
<template>
  <div class="d-flex flex-column">
    <p class="pt-3 js-subtitle-text" v-html="subtitleText"></p>
    <form v-if="showForm" class="js-quick-submit" @submit.prevent="submitForm">
      <tag-field />
      <gl-form-group>
        <label for="release-title">{{ __('Release title') }}</label>
        <gl-form-input
          id="release-title"
          ref="releaseTitleInput"
          v-model="releaseTitle"
          type="text"
          class="form-control"
        />
      </gl-form-group>
      <gl-form-group class="w-50" data-testid="milestones-field">
        <label>{{ __('Milestones') }}</label>
        <div class="d-flex flex-column col-md-6 col-sm-10 pl-0">
          <milestone-combobox
            v-model="releaseMilestones"
            :project-id="projectId"
            :extra-links="milestoneComboboxExtraLinks"
          />
        </div>
      </gl-form-group>
      <gl-form-group>
        <label for="release-notes">{{ __('Release notes') }}</label>
        <div class="bordered-box pr-3 pl-3">
          <markdown-field
            :can-attach-file="true"
            :markdown-preview-path="markdownPreviewPath"
            :markdown-docs-path="markdownDocsPath"
            :add-spacing-classes="false"
            class="gl-mt-3 gl-mb-3"
          >
            <template #textarea>
              <textarea
                id="release-notes"
                v-model="releaseNotes"
                class="note-textarea js-gfm-input js-autosize markdown-area"
                dir="auto"
                data-supports-quick-actions="false"
                :aria-label="__('Release notes')"
                :placeholder="__('Write your release notes or drag your files here…')"
              ></textarea>
            </template>
          </markdown-field>
        </div>
      </gl-form-group>

      <asset-links-form v-if="showAssetLinksForm" />

      <div class="d-flex pt-3">
        <gl-button
          class="mr-auto js-no-auto-disable"
          category="primary"
          variant="success"
          type="submit"
          :disabled="isFormSubmissionDisabled"
          data-testid="submit-button"
        >
          {{ saveButtonLabel }}
        </gl-button>
        <gl-button :href="cancelPath" class="js-cancel-button">{{ __('Cancel') }}</gl-button>
      </div>
    </form>
  </div>
</template>
