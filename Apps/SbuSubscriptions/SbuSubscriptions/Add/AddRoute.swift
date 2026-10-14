/// Where the add sheet goes next: a blank form, or one filled from the catalog.
enum AddRoute: Hashable {
    case custom
    case service(CatalogService)
}
