/**
 * Apparatuses for gymnastics events for each gender
 */
export const APPARATUSES = {
  MEN: ['FX', 'PH', 'SR', 'VT', 'PB', 'HB'],
  WOMEN: ['VT', 'UB', 'BB', 'FX'],
} as const;

/**
 * Cache keys for localStorage
 */
export const CACHE_KEYS = {
  assignments: 'ASSIGNMENTS_CACHE',
  gender: 'GENDER_CACHE',
  selectedTeam: 'SELECTED_CACHE',
} as const;

export const GENDERS = {
  MEN: 'm',
  WOMEN: 'w',
} as const;

/**
 * Useful types for type safety
 */
export type Apparatus = (typeof APPARATUSES)[keyof typeof APPARATUSES][number];
export type Gender = (typeof GENDERS)[keyof typeof GENDERS];
