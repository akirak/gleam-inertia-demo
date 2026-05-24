import { Head, router } from "@inertiajs/react";
import { MetadataPanel, ProtocolPage, useProtocolPage } from "./shared";
import styles from "../page.module.css";

type ScrollPost = {
  id: number;
  title: string;
  status: string;
};

type ScrollProps = {
  errors: Record<string, string>;
  posts: {
    data: ScrollPost[];
  };
};

export default function ScrollDemo() {
  const page = useProtocolPage<ScrollProps>();
  const scroll = page.scrollProps?.posts;

  const loadNextPage = () => {
    if (!scroll?.nextPage) {
      return;
    }

    router.reload({
      data: { page: String(scroll.nextPage) },
      only: ["posts"],
    });
  };

  return (
    <>
      <Head title="Scroll Props" />
      <ProtocolPage
        title="Scroll props"
        eyebrow="Inertia protocol demo"
        description="Infinite-scroll responses use merge metadata and pagination metadata together so new pages can append cleanly."
        objectTypeDescription="Scroll props describe how an infinite-scroll prop should merge paginated results and which page numbers exist before and after the current slice."
        documentationHref="https://inertiajs.com/infinite-scroll"
      >
        <section className={styles.panel}>
          <div className={styles.cluster}>
            <span className={styles.status} data-testid="scroll-current-page">
              Current page {scroll?.currentPage ?? "?"}
            </span>
            <span className={styles.status} data-testid="scroll-next-page">
              Next page {scroll?.nextPage ?? "none"}
            </span>
          </div>
        </section>

        <section className={styles.panel}>
          <h2 className={styles.sectionTitle}>Posts</h2>
          <ul className={styles.plainList} data-testid="scroll-posts">
            {page.props.posts.data.map((post) => (
              <li key={post.id} className={styles.itemCard}>
                <span className={styles.itemTitle}>{post.title}</span>
                <span className={styles.itemMeta}>
                  id={post.id} status={post.status}
                </span>
              </li>
            ))}
          </ul>
          <div className={styles.cluster}>
            <button
              className={styles.button}
              data-testid="scroll-load-next"
              disabled={!scroll?.nextPage}
              onClick={loadNextPage}
              type="button"
            >
              {scroll?.nextPage ? "Load next page" : "End of list"}
            </button>
          </div>
        </section>

        <MetadataPanel page={page} />
      </ProtocolPage>
    </>
  );
}
