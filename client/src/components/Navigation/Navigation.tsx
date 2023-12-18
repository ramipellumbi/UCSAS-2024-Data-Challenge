'use client';

import { useMemo, useState } from 'react';

import { rem, Title, Tooltip, UnstyledButton } from '@mantine/core';
import { IconDirectionHorizontal, IconEaseInOut } from '@tabler/icons-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

import classes from './Navigation.module.css';

const MAIN_LINKS = [
  { icon: IconDirectionHorizontal, label: 'Run Simulation', path: '/' },
  { icon: IconEaseInOut, label: 'Simulation Explorer', path: '/explorer' },
];

export function Navigation({ children }: { children: React.ReactNode }) {
  const pathName = usePathname();

  const [active, setActive] = useState(() => {
    const activeLink = MAIN_LINKS.find((link) => pathName.includes(link.path));
    return activeLink?.label || 'Home';
  });

  const mainLinks = useMemo(
    () =>
      MAIN_LINKS.map((link) => (
        <Tooltip
          label={link.label}
          position="right"
          withArrow
          transitionProps={{ duration: 0 }}
          key={link.label}
        >
          <Link href={link.path}>
            <UnstyledButton
              onClick={() => setActive(link.label)}
              className={classes.mainLink}
              data-active={link.label === active || undefined}
            >
              <link.icon style={{ width: rem(22), height: rem(22) }} stroke={1.5} />
            </UnstyledButton>
          </Link>
        </Tooltip>
      )),
    [setActive, active]
  );

  return (
    <div className={classes.navbar}>
      <div className={classes.aside}>
        <div className={classes.logo}></div>
        {mainLinks}
      </div>
      <div className={classes.main}>
        <Title order={4} className={classes.title}>
          UCSAS 2024 Gymnastics Data Challenge
        </Title>
        <div className={classes.mainContent}>{children}</div>
      </div>
    </div>
  );
}
