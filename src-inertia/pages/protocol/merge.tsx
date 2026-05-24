import { Head, router } from "@inertiajs/react";
import { MetadataPanel, ProtocolPage, useProtocolPage } from "./shared";
import styles from "../page.module.css";

type MergePost = {
  id: number;
  title: string;
  status: string;
};

type MergeAlert = {
  id: string;
  message: string;
};

type MergeProps = {
  errors: Record<string, string>;
  summary: {
    batch: number;
    totalPosts: number;
    headline: string;
  };
  posts: MergePost[];
  alerts: MergeAlert[];
  hasMore: boolean;
};

export default function MergeDemo() {
  const page = useProtocolPage<MergeProps>();
  const { summary, posts, alerts, hasMore } = page.props;

  const loadNextBatch = () => {
    router.reload({
      data: { batch: String(summary.batch + 1) },
      only: ["summary", "posts", "alerts", "hasMore"],
    });
  };

  return (
    <>
      <Head title="Merge Props" />
      <ProtocolPage
        title="Merge props"
        eyebrow="Inertia protocol demo"
        description="Partial reloads can append, prepend, and deep-merge specific props instead of replacing them outright."
        objectTypeDescription="Merge props tell the Inertia client which prop paths should be appended, prepended, deep-merged, or matched by key when a partial reload returns new data."
        documentationHref="https://inertiajs.com/docs/v3/data-props/merging-props"
      >
        <section className={styles.grid}>
          <article className={styles.panel}>
            <h2 className={styles.sectionTitle}>Posts</h2>
            <ul className={styles.plainList} data-testid="merge-posts">
              {posts.map((post) => (
                <li key={post.id} className={styles.itemCard}>
                  <span className={styles.itemTitle}>{post.title}</span>
                  <span className={styles.itemMeta}>
                    id={post.id} status={post.status}
                  </span>
                </li>
              ))}
            </ul>
          </article>

          <article className={styles.panel}>
            <h2 className={styles.sectionTitle}>Alerts</h2>
            <ul className={styles.plainList} data-testid="merge-alerts">
              {alerts.map((alert) => (
                <li key={alert.id} className={styles.itemCard}>
                  <span className={styles.itemTitle}>{alert.message}</span>
                  <span className={styles.itemMeta}>id={alert.id}</span>
                </li>
              ))}
            </ul>
          </article>
        </section>

        <section className={styles.panel}>
          <h2 className={styles.sectionTitle}>Summary</h2>
          <div className={styles.stack}>
            <span className={styles.status} data-testid="merge-summary">
              {summary.headline} | batch {summary.batch} | total {summary.totalPosts}
            </span>
            <div className={styles.cluster}>
              <button
                className={styles.button}
                data-testid="merge-next-batch"
                disabled={!hasMore}
                onClick={loadNextBatch}
                type="button"
              >
                {hasMore ? "Load next batch" : "No more batches"}
              </button>
            </div>
          </div>
        </section>

        <MetadataPanel page={page} />
      </ProtocolPage>
    </>
  );
}
