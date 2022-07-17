export default class LocalStorage {

    static getAuthToken(): string | null {
        return localStorage.getItem('token')
    }

    static setAuthToken(val: string): void {
        return localStorage.setItem('token', val)
    }
}


