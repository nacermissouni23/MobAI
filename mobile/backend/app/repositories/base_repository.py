"""
Base repository providing generic Firestore CRUD operations.
"""

from datetime import datetime
from typing import Any, Dict, Generic, List, Optional, Type, TypeVar
import asyncio
from concurrent.futures import ThreadPoolExecutor

from google.cloud.firestore import Query
from app.config.firebase import get_db
from app.core.exceptions import NotFoundError
from app.utils.logger import logger

T = TypeVar("T")

# Thread pool for running sync Firebase operations
_executor = ThreadPoolExecutor(max_workers=10)


class BaseRepository:
    """
    Generic Firestore CRUD repository.
    All entity repositories should inherit from this class.
    """

    def __init__(self, collection_name: str):
        self.collection_name = collection_name

    @property
    def _collection(self):
        """Return Firestore collection reference."""
        return get_db().collection(self.collection_name)

    # ── CREATE ───────────────────────────────────────────────────

    async def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new document in Firestore.

        Args:
            data: Dictionary of document fields.

        Returns:
            The created document data with its generated ID.
        """
        def _create():
            now = datetime.utcnow().isoformat()
            data["created_at"] = data.get("created_at", now)
            data["updated_at"] = now

            doc_ref = self._collection.document()
            doc_ref.set(data)
            data["id"] = doc_ref.id
            logger.debug(f"Created document in '{self.collection_name}': {doc_ref.id}")
            return data
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _create)

    async def create_with_id(self, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a document with a specific ID."""
        def _create_with_id():
            now = datetime.utcnow().isoformat()
            data["created_at"] = data.get("created_at", now)
            data["updated_at"] = now

            doc_ref = self._collection.document(doc_id)
            doc_ref.set(data)
            data["id"] = doc_id
            return data
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _create_with_id)

    # ── READ ─────────────────────────────────────────────────────

    async def get_by_id(self, doc_id: str) -> Optional[Dict[str, Any]]:
        """
        Get a single document by ID.

        Args:
            doc_id: Firestore document ID.

        Returns:
            Document data dict with 'id' field, or None if not found.
        """
        def _get_by_id():
            doc = self._collection.document(doc_id).get()
            if doc.exists:  # type: ignore
                data = doc.to_dict()  # type: ignore
                data["id"] = doc.id  # type: ignore
                return data
            return None
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _get_by_id)

    async def get_by_id_or_raise(self, doc_id: str) -> Dict[str, Any]:
        """Get a document by ID or raise NotFoundError."""
        result = await self.get_by_id(doc_id)
        if result is None:
            raise NotFoundError(self.collection_name, doc_id)
        return result

    async def get_all(self, limit: int = 1000) -> List[Dict[str, Any]]:
        """Get all documents in the collection."""
        def _get_all():
            docs = self._collection.limit(limit).stream()
            results = []
            for doc in docs:
                data = doc.to_dict()  # type: ignore
                data["id"] = doc.id  # type: ignore
                results.append(data)
            return results
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _get_all)

    async def query(
        self,
        filters: Optional[List[tuple]] = None,
        order_by: Optional[str] = None,
        direction: str = "ASCENDING",
        limit: int = 1000,
    ) -> List[Dict[str, Any]]:
        """
        Query documents with optional filters and ordering.

        Args:
            filters: List of tuples (field, operator, value).
                     e.g. [("status", "==", "active"), ("floor", ">=", 2)]
            order_by: Field name to order by.
            direction: "ASCENDING" or "DESCENDING".
            limit: Max results.

        Returns:
            List of matching document dicts.
        """
        def _query():
            query_ref = self._collection

            if filters:
                for field, op, value in filters:
                    query_ref = query_ref.where(field, op, value)

            if order_by:
                dir_const = (
                    Query.DESCENDING if direction == "DESCENDING" else Query.ASCENDING
                )
                query_ref = query_ref.order_by(order_by, direction=dir_const)

            query_ref = query_ref.limit(limit)
            results = []
            for doc in query_ref.stream():
                data = doc.to_dict()  # type: ignore
                data["id"] = doc.id  # type: ignore
                results.append(data)
            return results
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _query)

    async def find_one(self, field: str, value: Any) -> Optional[Dict[str, Any]]:
        """Find a single document where field equals value."""
        def _find_one():
            docs = self._collection.where(field, "==", value).limit(1).stream()
            for doc in docs:
                data = doc.to_dict()  # type: ignore
                data["id"] = doc.id  # type: ignore
                return data
            return None
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _find_one)

    # ── UPDATE ───────────────────────────────────────────────────

    async def update(self, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Update an existing document.

        Args:
            doc_id: Document ID.
            data: Fields to update.

        Returns:
            Updated document data.
        """
        def _update():
            # Remove None values
            update_data = {k: v for k, v in data.items() if v is not None}
            update_data["updated_at"] = datetime.utcnow().isoformat()

            doc_ref = self._collection.document(doc_id)
            doc = doc_ref.get()
            if not doc.exists:  # type: ignore
                raise NotFoundError(self.collection_name, doc_id)

            doc_ref.update(update_data)
            updated_doc = doc_ref.get().to_dict()  # type: ignore
            assert updated_doc is not None, "Document should exist after update"
            updated_doc["id"] = doc_id  # type: ignore
            logger.debug(f"Updated document in '{self.collection_name}': {doc_id}")
            return updated_doc
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _update)

    # ── DELETE ───────────────────────────────────────────────────

    async def delete(self, doc_id: str) -> bool:
        """
        Delete a document by ID.

        Args:
            doc_id: Document ID to delete.

        Returns:
            True if deleted.

        Raises:
            NotFoundError if document doesn't exist.
        """
        def _delete():
            doc_ref = self._collection.document(doc_id)
            doc = doc_ref.get()
            if not doc.exists:  # type: ignore
                raise NotFoundError(self.collection_name, doc_id)

            doc_ref.delete()
            logger.debug(f"Deleted document from '{self.collection_name}': {doc_id}")
            return True
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _delete)

    # ── BATCH ────────────────────────────────────────────────────

    async def batch_create(self, items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Create multiple documents in a batch."""
        def _batch_create():
            db = get_db()
            batch = db.batch()
            now = datetime.utcnow().isoformat()
            results = []

            for item in items:
                item["created_at"] = item.get("created_at", now)
                item["updated_at"] = now
                doc_ref = self._collection.document()
                batch.set(doc_ref, item)
                item["id"] = doc_ref.id
                results.append(item)

            batch.commit()
            logger.debug(f"Batch created {len(items)} documents in '{self.collection_name}'")
            return results
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _batch_create)

    async def count(self, filters: Optional[List[tuple]] = None) -> int:
        """Count documents matching optional filters."""
        def _count():
            query_ref = self._collection
            if filters:
                for field, op, value in filters:
                    query_ref = query_ref.where(field, op, value)
            # Stream and count
            return sum(1 for _ in query_ref.stream())
            
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(_executor, _count)
