import { Link, usePage } from "@inertiajs/react";
import type { ReactNode } from "react";
import Layout from "../../components/Layout";
import styles from "../page.module.css";

type ScrollMetadata = {
  pageName: string;
  previousPage: number | null;
  nextPage: number | null;
  currentPage: number;
};

type OnceMetadata = {
  prop: string;
  expiresAt: number | null;
};

export type ProtocolPageObject<Props> = {
  component: string;
  url: string;
  props: Props;
  deferredProps?: Record<string, string[]>;
  rescuedProps?: string[];
  mergeProps?: string[];
  prependProps?: string[];
  deepMergeProps?: string[];
  matchPropsOn?: string[];
  scrollProps?: Record<string, ScrollMetadata>;
  onceProps?: Record<string, OnceMetadata>;
};

export function useProtocolPage<Props>(): ProtocolPageObject<Props> {
  return usePage<Props>() as unknown as ProtocolPageObject<Props>;
}

type ProtocolPageProps = {
  title: string;
  eyebrow: string;
  description: string;
  objectTypeDescription: string;
  documentationHref: string;
  children: ReactNode;
};

export function ProtocolPage({
  title,
  eyebrow,
  description,
  objectTypeDescription,
  documentationHref,
  children,
}: ProtocolPageProps) {
  return (
    <Layout>
      <section className={styles.stack}>
        <p className={styles.eyebrow}>{eyebrow}</p>
        <h1 className={styles.title}>{title}</h1>
        <p className={styles.lede}>{description}</p>
        <nav className={styles.cluster} aria-label="Protocol demos">
          <Link href="/protocol/deferred">Deferred</Link>
          <Link href="/protocol/deferred-rescue">Rescued deferred</Link>
          <Link href="/protocol/merge">Merge</Link>
          <Link href="/protocol/scroll">Scroll</Link>
          <Link href="/protocol/once/source">Once</Link>
        </nav>
        <section className={styles.panel}>
          <h2 className={styles.sectionTitle}>About this object type</h2>
          <div className={styles.stack}>
            <p className={styles.lede}>{objectTypeDescription}</p>
            <a href={documentationHref} rel="noreferrer" target="_blank">
              Read the official Inertia documentation
            </a>
          </div>
        </section>
        {children}
      </section>
    </Layout>
  );
}

type MetadataPanelProps = {
  page: ProtocolPageObject<unknown>;
};

export function MetadataPanel({ page }: MetadataPanelProps) {
  const metadata = {
    component: page.component,
    url: page.url,
    deferredProps: page.deferredProps,
    rescuedProps: page.rescuedProps,
    mergeProps: page.mergeProps,
    prependProps: page.prependProps,
    deepMergeProps: page.deepMergeProps,
    matchPropsOn: page.matchPropsOn,
    scrollProps: page.scrollProps,
    onceProps: page.onceProps,
  };

  return (
    <section className={styles.panel}>
      <h2 className={styles.sectionTitle}>Page object metadata</h2>
      <pre className={styles.code} data-testid="protocol-metadata">
        {JSON.stringify(metadata, null, 2)}
      </pre>
    </section>
  );
}
