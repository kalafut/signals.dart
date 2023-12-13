typedef AsyncSignalError = (Object, StackTrace?);

// ignore_for_file: public_member_api_docs, sort_constructors_first
/// State for an [AsyncSignal]
sealed class AsyncSignalState<T> {
  final bool isLoading;
  final T? _value;
  final AsyncSignalError? _error;

  const AsyncSignalState({
    required this.isLoading,
    required T? value,
    required AsyncSignalError? error,
  })  : _value = value,
        _error = error;

  factory AsyncSignalState.data(T data) {
    return AsyncSignalStateData<T>(data);
  }

  factory AsyncSignalState.error(AsyncSignalError error) {
    return AsyncSignalStateError<T>(error);
  }

  factory AsyncSignalState.loading() {
    return AsyncSignalStateLoading<T>();
  }

  bool get hasValue;

  bool get hasError;

  bool get isRefreshing =>
      isLoading &&
      (hasValue || hasError) &&
      this is! AsyncSignalStateLoading<T>;

  bool get isReloading =>
      (hasValue || hasError) && this is AsyncSignalStateLoading<T>;

  T get requireValue => _value!;

  T? get value => _value;

  Object? get error => _error?.$1;

  StackTrace? get stackTrace => _error?.$2;

  E map<E>({
    required E Function(T value) data,
    required E Function(Object error, StackTrace? trace) error,
    required E Function() loading,
    E Function()? reloading,
    E Function()? refreshing,
  }) {
    if (isRefreshing) if (refreshing != null) return refreshing();
    if (isReloading) if (reloading != null) return reloading();
    if (hasValue) return data(value as T);
    if (hasError) return error(this.error!, this.stackTrace);
    return loading();
  }

  E maybeMap<E>({
    E Function(T value)? data,
    E Function(Object error, StackTrace? trace)? error,
    E Function()? loading,
    E Function()? reloading,
    E Function()? refreshing,
    required E Function() orElse,
  }) {
    if (isRefreshing) return refreshing != null ? refreshing() : orElse();
    if (isReloading) return reloading != null ? reloading() : orElse();
    if (hasValue) return data != null ? data(requireValue) : orElse();
    if (hasError) {
      if (error != null) return error(this.error!, this.stackTrace);
      return orElse();
    }
    if (isLoading) return loading != null ? loading() : orElse();
    return orElse();
  }

  @override
  bool operator ==(covariant AsyncSignalState<T> other) {
    if (identical(this, other)) return true;
    return other.hasError == hasError &&
        other.hasValue == hasValue &&
        other.isLoading == isLoading &&
        other.isRefreshing == isRefreshing &&
        other.isReloading == isReloading &&
        other._value == _value &&
        other._error == _error;
  }

  @override
  int get hashCode {
    return hasError.hashCode ^
        hasValue.hashCode ^
        isLoading.hashCode ^
        isRefreshing.hashCode ^
        isReloading.hashCode ^
        _value.hashCode ^
        _error.hashCode;
  }
}

class AsyncSignalStateData<T> extends AsyncSignalState<T> {
  AsyncSignalStateData(
    T data, {
    super.isLoading = false,
    super.error,
  }) : super(value: data);

  AsyncSignalStateData<T> toLoading() {
    return AsyncSignalStateData<T>(
      requireValue,
      isLoading: true,
    );
  }

  @override
  bool get hasValue => true;

  @override
  bool get hasError => false;
}

class AsyncSignalStateError<T> extends AsyncSignalState<T> {
  AsyncSignalStateError(
    AsyncSignalError err, {
    super.isLoading = false,
    super.value,
  }) : super(error: err);

  AsyncSignalStateError<T> toLoading() {
    return AsyncSignalStateError<T>(
      (error!, stackTrace),
      isLoading: true,
    );
  }

  @override
  bool get hasValue => false;

  @override
  bool get hasError => true;
}

class AsyncSignalStateLoading<T> extends AsyncSignalState<T> {
  AsyncSignalStateLoading({
    super.value,
    super.error,
    super.isLoading = true,
  });

  @override
  bool get hasValue => false;

  @override
  bool get hasError => false;
}
