import { Head, router } from "@inertiajs/react";
import { MetadataPanel, ProtocolPage, useProtocolPage } from "../shared";
import styles from "../../page.module.css";

type CatalogItem = {
  id: number;
  name: string;
};

type OnceSourceProps = {
  errors: Record<string, string>;
  pageLabel: string;
  serverLabel: string;
  plans: {
    generatedAt: string;
    items: CatalogItem[];
  };
};

export default function OnceSourceDemo() {
  const page = useProtocolPage<OnceSourceProps>();
  const goToTarget = () => {
    router.visit("/protocol/once/target");
  };

  return (
    <>
      <Head title="Once Props" />
      <ProtocolPage
        title="Once props"
        eyebrow="Inertia protocol demo"
        description="This page loads a once prop under one name, then the next page reuses the same cached value under a different prop name."
        objectTypeDescription="Once props are remembered by the Inertia client after the first visit and can be reused on later pages, including under a different prop name when the same once key is shared."
        documentationHref="https://inertiajs.com/docs/v3/data-props/once-props"
      >
        <section className={styles.panel}>
          <div className={styles.stack}>
            <span className={styles.status} data-testid="once-source-token">
              {page.props.plans.generatedAt}
            </span>
            <span className={styles.muted}>server label: {page.props.serverLabel}</span>
            <ul className={styles.plainList}>
              {page.props.plans.items.map((item) => (
                <li key={item.id} className={styles.itemCard}>
                  <span className={styles.itemTitle}>{item.name}</span>
                  <span className={styles.itemMeta}>id={item.id}</span>
                </li>
              ))}
            </ul>
            <div className={styles.cluster}>
              <button
                className={`${styles.button} ${styles.buttonSecondary}`}
                data-testid="visit-once-target"
                onClick={goToTarget}
                type="button"
              >
                Go to target page
              </button>
            </div>
          </div>
        </section>

        <MetadataPanel page={page} />
      </ProtocolPage>
    </>
  );
}
