FROM tinysearch/cli:202209271630475d98c3

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
