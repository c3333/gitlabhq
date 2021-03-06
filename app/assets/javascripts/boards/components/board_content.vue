<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import BoardColumn from 'ee_else_ce/boards/components/board_column.vue';
import { GlAlert } from '@gitlab/ui';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    BoardColumn,
    BoardContentSidebar: () => import('ee_component/boards/components/board_content_sidebar.vue'),
    EpicsSwimlanes: () => import('ee_component/boards/components/epics_swimlanes.vue'),
    GlAlert,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    lists: {
      type: Array,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: true,
    },
    groupId: {
      type: Number,
      required: false,
      default: null,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    issueLinkBase: {
      type: String,
      required: true,
    },
    rootPath: {
      type: String,
      required: true,
    },
    boardId: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['boardLists', 'error']),
    ...mapGetters(['isSwimlanesOn']),
    boardListsToUse() {
      return this.glFeatures.graphqlBoardLists ? this.boardLists : this.lists;
    },
  },
  mounted() {
    if (this.glFeatures.graphqlBoardLists) {
      this.fetchLists();
      this.showPromotionList();
    }
  },
  methods: {
    ...mapActions(['fetchLists', 'showPromotionList']),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <div
      v-if="!isSwimlanesOn"
      class="boards-list gl-w-full gl-py-5 gl-px-3 gl-white-space-nowrap"
      data-qa-selector="boards_list"
    >
      <board-column
        v-for="list in boardListsToUse"
        :key="list.id"
        ref="board"
        :can-admin-list="canAdminList"
        :group-id="groupId"
        :list="list"
        :disabled="disabled"
        :issue-link-base="issueLinkBase"
        :root-path="rootPath"
        :board-id="boardId"
      />
    </div>

    <template v-else>
      <epics-swimlanes
        ref="swimlanes"
        :lists="boardLists"
        :can-admin-list="canAdminList"
        :disabled="disabled"
        :board-id="boardId"
        :group-id="groupId"
        :root-path="rootPath"
      />
      <board-content-sidebar />
    </template>
  </div>
</template>
