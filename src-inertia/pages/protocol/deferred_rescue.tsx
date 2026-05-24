import { Head, router } from "@inertiajs/react";
import { useState } from "react";
import { MetadataPanel, ProtocolPage, useProtocolPage } from "./shared";
import styles from "../page.module.css";

type DeferredRescueProps = {
  errors: Record<string, string>;
  summary: string;
  permissions?: string[];
};

export default function DeferredRescueDemo() {
  const page = useProtocolPage<DeferredRescueProps>();
  const [isRetrying, setIsRetrying] = useState(false);
  const rescued = page.rescuedProps?.includes("permissions") ?? false;

  const requestPermissions = () => {
    setIsRetrying(true);

    router.reload({
      only: ["permissions"],
      onFinish: () => setIsRetrying(false),
    });
  };

  const retry = () => {
    setIsRetrying(true);

    router.reload({
      data: { retry: "1" },
      only: ["permissions"],
      onFinish: () => setIsRetrying(false),
    });
  };

  return (
    <>
      <Head title="Rescued Deferred Props" />
      <ProtocolPage
        title="Rescued deferred props"
        eyebrow="Inertia protocol demo"
        description={page.props.summary}
        objectTypeDescription="A rescued deferred prop is a deferred prop that failed to resolve server-side but was intentionally omitted from props and listed in rescuedProps so the client can show a retry path."
        documentationHref="https://inertiajs.com/docs/v3/data-props/deferred-props"
      >
        <section className={styles.panel}>
          <h2 className={styles.sectionTitle}>Permissions</h2>
          {page.props.permissions ? (
            <ul className={styles.plainList} data-testid="rescued-permissions-list">
              {page.props.permissions.map((permission) => (
                <li key={permission} className={styles.itemCard}>
                  <span className={styles.itemTitle}>{permission}</span>
                </li>
              ))}
            </ul>
          ) : rescued ? (
            <div className={styles.stack} data-testid="rescued-state">
              <span className={styles.status}>Deferred prop was rescued</span>
              <button
                className={styles.button}
                data-testid="retry-permissions"
                disabled={isRetrying}
                onClick={retry}
                type="button"
              >
                {isRetrying ? "Retrying" : "Retry permissions"}
              </button>
            </div>
          ) : (
            <div className={styles.stack} data-testid="rescued-loading">
              <span className={styles.status}>Deferred permissions are omitted at first</span>
              <button
                className={styles.button}
                data-testid="request-rescued"
                disabled={isRetrying}
                onClick={requestPermissions}
                type="button"
              >
                {isRetrying ? "Requesting" : "Request deferred permissions"}
              </button>
            </div>
          )}
        </section>

        <MetadataPanel page={page} />
      </ProtocolPage>
    </>
  );
}
