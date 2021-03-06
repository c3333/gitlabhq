import { STATUSES } from '../constants';
import { isProjectImportable, isIncompatible } from '../utils';

export const isLoading = state => state.isLoadingRepos || state.isLoadingNamespaces;

export const isImportingAnyRepo = state =>
  state.repositories.some(repo =>
    [STATUSES.SCHEDULING, STATUSES.SCHEDULED, STATUSES.STARTED].includes(
      repo.importedProject?.importStatus,
    ),
  );

export const hasIncompatibleRepos = state => state.repositories.some(isIncompatible);

export const hasImportableRepos = state => state.repositories.some(isProjectImportable);

export const getImportTarget = state => repoId => {
  if (state.customImportTargets[repoId]) {
    return state.customImportTargets[repoId];
  }

  const repo = state.repositories.find(r => r.importSource.id === repoId);

  return {
    newName: repo.importSource.sanitizedName,
    targetNamespace: state.defaultTargetNamespace,
  };
};
