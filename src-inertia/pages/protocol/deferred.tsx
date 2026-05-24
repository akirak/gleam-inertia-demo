import { Head, router } from "@inertiajs/react";
import { MetadataPanel, ProtocolPage, useProtocolPage } from "./shared";
import styles from "../page.module.css";

type DeferredDemoProps = {
  errors: Record<string, string>;
  summary: string;
  permissions?: string[];
  analytics?: {
    activeUsers: number;
    p95LatencyMs: number;
    queueDepth: number;
  };
};

export default function DeferredDemo() {
  const page = useProtocolPage<DeferredDemoProps>();
  const { summary, permissions, analytics } = page.props;
  const loadDeferredProps = () => {
    router.reload({
      only: ["permissions", "analytics"],
    });
  };

  return (
    <>
      <Head title="Deferred Props" />
      <ProtocolPage
        title="Deferred props"
        eyebrow="Inertia protocol demo"
        description={summary}
        objectTypeDescription="A deferred prop is declared in the page object metadata first, then resolved in a follow-up request so the initial page can render without waiting for slower data."
        documentationHref="https://inertiajs.com/docs/v3/data-props/deferred-props"
      >
        <section className={styles.grid}>
          <article className={styles.panel}>
            <h2 className={styles.sectionTitle}>Permissions</h2>
            {permissions ? (
              <ul className={styles.plainList} data-testid="permissions-list">
                {permissions.map((permission) => (
                  <li key={permission} className={styles.itemCard}>
                    <span className={styles.itemTitle}>{permission}</span>
                  </li>
                ))}
              </ul>
            ) : (
              <div className={styles.stack}>
                <span className={styles.status} data-testid="permissions-loading">
                  Deferred permissions are not in the initial payload
                </span>
                <button
                  className={styles.button}
                  data-testid="load-deferred"
                  onClick={loadDeferredProps}
                  type="button"
                >
                  Load deferred props
                </button>
              </div>
            )}
          </article>

          <article className={styles.panel}>
            <h2 className={styles.sectionTitle}>Analytics</h2>
            {analytics ? (
              <ul className={styles.plainList} data-testid="analytics-panel">
                <li className={styles.itemCard}>
                  <span className={styles.itemTitle}>Active users</span>
                  <span className={styles.itemMeta}>{analytics.activeUsers}</span>
                </li>
                <li className={styles.itemCard}>
                  <span className={styles.itemTitle}>P95 latency</span>
                  <span className={styles.itemMeta}>{analytics.p95LatencyMs} ms</span>
                </li>
                <li className={styles.itemCard}>
                  <span className={styles.itemTitle}>Queue depth</span>
                  <span className={styles.itemMeta}>{analytics.queueDepth}</span>
                </li>
              </ul>
            ) : (
              <span className={styles.status} data-testid="analytics-loading">
                Loading deferred analytics
              </span>
            )}
          </article>
        </section>

        <MetadataPanel page={page} />
      </ProtocolPage>
    </>
  );
}
