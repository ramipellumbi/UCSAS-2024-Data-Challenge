/**
 * Apparatuses for gymnastics events for each gender
 */
export const APPARATUSES = {
  m: ['FX', 'PH', 'SR', 'VT', 'PB', 'HB'],
  w: ['VT', 'UB', 'BB', 'FX'],
} as const;

/**
 * Cache keys for localStorage
 */
export const CACHE_KEYS = {
  assignments: 'ASSIGNMENTS_CACHE',
  gender: 'GENDER_CACHE',
  selectedTeam: 'SELECTED_CACHE',
} as const;

/**
 * Useful types for type safety
 */

export type Apparatus = (typeof APPARATUSES)[keyof typeof APPARATUSES][number];
export type Apparatuses = typeof APPARATUSES;
export type Gender = 'm' | 'w';
