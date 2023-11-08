export const APPARATUSES = {
  m: ['FX', 'PH', 'SR', 'VT', 'PB', 'HB'],
  w: ['VT', 'UB', 'BB', 'FX'],
} as const;

export const CACHE_KEYS = {
  assignments: 'ASSIGNMENTS_CACHE',
  gender: 'GENDER_CACHE',
  selectedTeam: 'SELECTED_CACHE',
} as const;

export const GENDERS = {
  MEN: 'm',
  WOMEN: 'w',
} as const;

export type Apparatus = (typeof APPARATUSES)[keyof typeof APPARATUSES][number];
export type Gender = (typeof GENDERS)[keyof typeof GENDERS];
