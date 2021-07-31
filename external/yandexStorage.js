const storageKey = 'saveData';

let localStorage = null;
try {
    localStorage = window.localStorage || null;
} catch (ignore) {}

class YandexStorage {
    constructor(store = {}, scopes = true) {
        this.scopes = scopes;
        this.player = null;

        this.store = Object.assign(
            store,
            JSON.parse(localStorage && localStorage.getItem(storageKey))
        );
    }

    init(sdk) {
        sdk.getStorage().then((safeStorage) => {
            localStorage = safeStorage;
            Object.assign(
                this.store,
                JSON.parse(localStorage.getItem(storageKey))
            );
        });

        return sdk
            .getPlayer({ scopes: this.scopes })
            .then((player) => {
                this.player = player;
                return player.getData();
            })
            .then((data) => {
                Object.assign(this.store, data);
                return this;
            });
    }

    set(data, flush) {
        Object.assign(this.store, data);
        localStorage &&
            localStorage.setItem(storageKey, JSON.stringify(this.store));
        const promise = this.player && this.player.setData(this.store, flush);
        return flush && (promise || Promise.reject());
    }

    get(keys) {
        const result = {};
        keys.forEach((key) => {
            result[key] = this.store[key];
        });
        return result;
    }

    flush() {
        return this.set(null, true);
    }
}

export default YandexStorage;
