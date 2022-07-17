import ApolloClient, {gql} from "apollo-boost";
import LocalStorage from "../utils/localStorage";

export default class Api {

    private static instance: Api

    private client

    public static getInstance(): Api {
        if (!Api.instance) {
            Api.instance = new Api();
        }

        return Api.instance;
    }

    private constructor() {
        this.client = new ApolloClient({
            uri: 'http://127.0.0.1:4000/graphql'
        })
    }

    login(email: String, password: String) {
        return this.client.mutate({
            mutation: gql`
              mutation makeLogin($email: String!, $password: String!) {
                login(email: $email, password: $password) {
                  ... on LoginSuccess {
                    token
                    identifier
                  }
                  ... on LoginFailure {
                    error
                  }
                }
              }`
            ,
            variables: {
                email: email,
                password: password
            },
        }).then((res) => {
            return res?.data?.login
        })
    }

}