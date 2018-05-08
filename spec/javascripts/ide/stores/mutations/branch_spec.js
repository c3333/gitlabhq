import mutations from '~/ide/stores/mutations/branch';
import state from '~/ide/stores/state';

describe('Multi-file store branch mutations', () => {
  let localState;

  beforeEach(() => {
    localState = state();
  });

  describe('SET_CURRENT_BRANCH', () => {
    it('sets currentBranch', () => {
      mutations.SET_CURRENT_BRANCH(localState, 'master');

      expect(localState.currentBranchId).toBe('master');
    });
  });

  describe('SET_BRANCH_COMMIT', () => {
    it('sets the last commit on current project', () => {
      localState.projects = {
        Example: {
          branches: {
            master: {},
          },
        },
      };

      mutations.SET_BRANCH_COMMIT(localState, {
        projectId: 'Example',
        branchId: 'master',
        commit: {
          title: 'Example commit',
        },
      });

      expect(localState.projects.Example.branches.master.commit.title).toBe('Example commit');
    });
  });

  describe('SET_LAST_COMMIT_PIPELINE', () => {
    it('sets the pipeline for the last commit on current project', () => {
      localState.projects = {
        Example: {
          branches: {
            master: {
              commit: {},
            },
          },
        },
      };

      mutations.SET_LAST_COMMIT_PIPELINE(localState, {
        projectId: 'Example',
        branchId: 'master',
        pipeline: {
          id: 42,
          ref: 'master',
          status: 'failed',
        },
      });

      expect(localState.projects.Example.branches.master.commit.pipeline.id).toBe(42);
      expect(localState.projects.Example.branches.master.commit.pipeline.ref).toBe('master');
      expect(localState.projects.Example.branches.master.commit.pipeline.status).toBe('failed');
    });
  });
});
